//
//  AppVersionManagerPlugin.swift
//  App
//
//  Created by TeamCity Agent on 02.12.2025.
//
import Foundation
import Capacitor

@objc(AppVersionManagerPlugin)
public class AppVersionManagerPlugin : CAPPlugin, CAPBridgedPlugin {
    public let identifier = "AppVersionManagerPlugin"
    public let jsName = "AppVersionManager"
    
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "checkForUpdate", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "notifyNewRelease", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getCurrentVersion", returnType: CAPPluginReturnPromise)
    ]
    
    private struct NotificationDecision {
        let shouldShow: Bool
        let reason: String
        let isCritical: Bool
    }
    
    @objc public func checkForUpdate(_ call: CAPPluginCall) {
        let bundleId = call.getString("iosBundleId")
        let country = call.getString("country")
        let optionsRaw = call.getObject("options")
        let options = AppVersionManagerOptions(from: optionsRaw)
        
        fetchBothVersions(
            country: country,
            bundleId: bundleId,
            options: options,
            call: call
        ) { currentApp, releaseApp, bundleIdentifier in
            let comparator = VersionComparator(currentApp: currentApp, releaseApp: releaseApp, criticalUpdateVersion: nil)
            
            call.resolve([
                "updateAvailable": comparator.shouldNotify,
                "app": self.buildAppInfo(
                    currentApp: currentApp,
                    releaseApp: releaseApp,
                    bundleIdentifier: bundleIdentifier
                )
            ])
        }
    }
    
    @objc public func notifyNewRelease(_ call: CAPPluginCall) {
        let bundleId = call.getString("iosBundleId")
        let country = call.getString("country")
        let optionsRaw = call.getObject("options")
        let options = AppVersionManagerOptions(from: optionsRaw)
        let alertOptions = NotifyNewReleaseOptions(from: optionsRaw)
        
        fetchBothVersions(
            country: country,
            bundleId: bundleId,
            options: options,
            call: call
        ) { currentApp, releaseApp, bundleIdentifier in
            
            let comparator = VersionComparator(
                currentApp: currentApp,
                releaseApp: releaseApp,
                criticalUpdateVersion: alertOptions.critical
            )
            
            let scheduler = UpdateNotificationScheduler(_options: alertOptions)
            
            let decision = self.evaluateNotificationDecision(
                comparator: comparator,
                scheduler: scheduler,
                options: alertOptions
            )
            
            let appInfo = self.buildAppInfo(
                currentApp: currentApp,
                releaseApp: releaseApp,
                bundleIdentifier: bundleIdentifier
            )
            
            if decision.shouldShow {
                self.presentUpdateAlert(
                    currentApp: currentApp,
                    releaseApp: releaseApp,
                    alertOptions: alertOptions,
                    commonOptions: options,
                    country: country,
                    scheduler: scheduler,
                    isCritical: decision.isCritical,
                    onPresented: {
                        call.resolve([
                            "notified": true,
                            "reason": decision.reason,
                            "isCritical": decision.isCritical,
                            "app": appInfo,
                            "skippedByScheduler": false,
                            "schedulerDebugInfo": scheduler.getDebugInfo()
                        ])
                    }
                )
            } else {
                call.resolve([
                    "notified": false,
                    "reason": decision.reason,
                    "isCritical": decision.isCritical,
                    "app": appInfo,
                    "skippedByScheduler": decision.reason == "skipped_by_scheduler",
                    "schedulerDebugInfo": scheduler.getDebugInfo()
                ])
            }
        }
    }
    
    private func evaluateNotificationDecision(
        comparator: VersionComparator,
        scheduler: UpdateNotificationScheduler,
        options: NotifyNewReleaseOptions
    ) -> NotificationDecision {
        
        let hasUpdate = comparator.shouldNotify
        let isCritical = comparator.isUpdateCritical
        let isForced = options.forceNotify == true
        
        if !hasUpdate && !isForced {
            return NotificationDecision(shouldShow: false, reason: "no_update", isCritical: isCritical)
        }
        
        if isForced {
            return NotificationDecision(shouldShow: true, reason: "forced", isCritical: isCritical)
        }
        
        if isCritical {
            return NotificationDecision(shouldShow: true, reason: "critical", isCritical: true)
        }
        
        if scheduler.shouldShowNotification() {
            return NotificationDecision(shouldShow: true, reason: "scheduled", isCritical: false)
        }
        
        return NotificationDecision(shouldShow: false, reason: "skipped_by_scheduler", isCritical: false)
    }
    
    @objc public func getCurrentVersion(_ call: CAPPluginCall) {
        let bundleId = call.getString("iosBundleId")
        let country = call.getString("country")
        let optionsRaw = call.getObject("options")
        let options = AppVersionManagerOptions(from: optionsRaw)
        
        fetchBothVersions(
            country: country,
            bundleId: bundleId,
            options: options,
            call: call
        ) { currentApp, releaseApp, bundleIdentifier in
            call.resolve([
                "app": self.buildAppInfo(
                    currentApp: currentApp,
                    releaseApp: releaseApp,
                    bundleIdentifier: bundleIdentifier
                )
            ])
        }
    }
    
    private func fetchBothVersions(
        country: String?,
        bundleId: String?,
        options: AppVersionManagerOptions,
        call: CAPPluginCall,
        completion: @escaping (AppVersion, AppVersion, String) -> Void
    ) {
        let versionHelper = VersionHelper()
        let storeVersionFetcher = StoreVersionFetcher()
        
        guard let currentApp = versionHelper.getCurrentAppVersion() else {
            call.reject("Unable to get current app version. Make sure the app's Info.plist contains CFBundleShortVersionString and CFBundleVersion.")
            return
        }
        
        storeVersionFetcher.getReleaseAppVersion(
            country: country,
            bundleId: bundleId,
            options: options
        ) { releaseApp in
            guard let releaseApp = releaseApp else {
                call.reject(self.getStoreVersionFetchErrorMessage())
                return
            }
            
            let bundleIdentifier = bundleId ?? Bundle.main.bundleIdentifier ?? "unknown"
            
            completion(currentApp, releaseApp, bundleIdentifier)
        }
    }
    
    private func buildAppInfo(
        currentApp: AppVersion,
        releaseApp: AppVersion,
        bundleIdentifier: String
    ) -> [String: Any] {
        return [
            "current": [
                "version": currentApp.version,
                "buildNumber": currentApp.buildNumber,
                "versionString": currentApp.fullVersion
            ],
            "release": [
                "version": releaseApp.version,
                "buildNumber": releaseApp.buildNumber,
                "versionString": releaseApp.fullVersion
            ],
            "bundleIdentifier": bundleIdentifier
        ]
    }
    
    private func presentUpdateAlert(
        currentApp: AppVersion,
        releaseApp: AppVersion,
        alertOptions: NotifyNewReleaseOptions,
        commonOptions: AppVersionManagerOptions,
        country: String?,
        scheduler: UpdateNotificationScheduler,
        isCritical: Bool,
        onPresented: @escaping () -> Void
    ) {
        let presenter = UpdateAlertPresenter(
            currentApp: currentApp,
            releaseApp: releaseApp,
            options: alertOptions,
            scheduler: scheduler
        )
        
        let countryHelper = CountryHelper(country: country, options: commonOptions)
        
        presenter.present(
            onPresented: onPresented,
            country: countryHelper.countryCode,
            isCritical: isCritical
        )
    }
    
    private func getStoreVersionFetchErrorMessage() -> String {
        return """
            Unable to fetch release app version from App Store. \
            Try to provide correct bundleId and/or country code manually. \
            By default, the plugin attempts to determine the app's installation country automatically. \
            The country parameter will be used if the country cannot be set. This usually happens on an emulator. \
            If you are using an emulator, check your computer's geolocation settings. \
            If you want manually control application country please set forceCountry: true.
            """
    }
}
