//
//  UpdateAlertPresenter.swift
//  App
//
//  Created by   TeamCity Agent on 04.12.2025.
//

import Foundation
import UIKit
import Capacitor

public class UpdateAlertPresenter {
    
    private let currentApp: AppVersion
    private let releaseApp: AppVersion
    private let options: NotifyNewReleaseOptions
    private let scheduler: UpdateNotificationScheduler
    
    public init(
        currentApp: AppVersion,
        releaseApp: AppVersion,
        options: NotifyNewReleaseOptions,
        scheduler: UpdateNotificationScheduler
    ) {
        self.currentApp = currentApp
        self.releaseApp = releaseApp
        self.options = options
        self.scheduler = scheduler
    }
    
    public func present(onPresented: @escaping () -> Void, country: String?, isCritical: Bool) {
        DispatchQueue.main.async {
            let title = self.getEffectiveTitle(isCritical: isCritical)
            let message = self.parseMessage()
            let closeButtonTitle = self.options.buttonCloseText ?? self.getLocalizedCloseButton()
            let updateButtonTitle = self.options.buttonUpdateText ?? self.getLocalizedUpdateButton()
            
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )
            
            if isCritical == false {
                alert.addAction(UIAlertAction(
                    title: closeButtonTitle,
                    style: .cancel,
                    handler: { _ in
                        self.scheduler.markNotificationDismissed()
                    }
                ))
            }
            
            alert.addAction(UIAlertAction(
                title: updateButtonTitle,
                style: .default,
                handler: { _ in
                    if !isCritical {
                        self.scheduler.markNotificationDismissed()
                    }
                    
                    if let appStoreLink = self.options.appStoreLink,
                       !appStoreLink.isEmpty,
                       let url = URL(string: appStoreLink) {
                        self.openAppStoreByUrl(url: url)
                        return
                    }
                    
                    self.openAppStore(country: country)
                }
            ))
            
            if let viewController = self.getTopViewController() {
                viewController.present(alert, animated: true) {
                    onPresented()
                }
            } else {
                onPresented()
            }
        }
    }
    
    private func getEffectiveTitle(isCritical: Bool) -> String {
        if let customTitle = self.options.title {
            return isCritical ? "⚠️ \(customTitle)" : customTitle
        }
        
        if isCritical {
            return NSLocalizedString(
                "update_required_title",
                tableName: nil,
                bundle: Bundle.main,
                value: "⚠️ Update Required",
                comment: "Title for critical update"
            )
        } else {
            return self.getLocalizedTitle()
        }
    }
    
    
    private func parseMessage() -> String {
        guard let customMessage = self.options.message, !customMessage.isEmpty else {
            return getLocalizedDefaultMessage()
        }
        
        var parsedMessage = customMessage
        
        if parsedMessage.contains("#current") {
            parsedMessage = parsedMessage.replacingOccurrences(
                of: "#current",
                with: currentApp.version
            )
        }
        
        if parsedMessage.contains("#release") {
            parsedMessage = parsedMessage.replacingOccurrences(
                of: "#release",
                with: releaseApp.version
            )
        }
        
        return parsedMessage
    }
    
    private func getLocalizedTitle() -> String {
        return NSLocalizedString(
            "update_available_title",
            tableName: nil,
            bundle: Bundle.main,
            value: "Update Available",
            comment: "Title for update alert"
        )
    }
    
    private func getLocalizedDefaultMessage() -> String {
        let format = NSLocalizedString(
            "update_available_message",
            tableName: nil,
            bundle: Bundle.main,
            value: "A new version (%@) is available. You are currently using version %@.",
            comment: "Message for update alert"
        )
        
        return String(format: format, releaseApp.version, currentApp.version)
    }
    
    private func getLocalizedCloseButton() -> String {
        return NSLocalizedString(
            "update_close_button",
            tableName: nil,
            bundle: Bundle.main,
            value: "Not Now",
            comment: "Close button for update alert"
        )
    }
    
    private func getLocalizedUpdateButton() -> String {
        return NSLocalizedString(
            "update_button",
            tableName: nil,
            bundle: Bundle.main,
            value: "Update",
            comment: "Update button for update alert"
        )
    }
    
    
    private func openAppStoreByUrl(url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    private func openAppStore(country: String?) {
        guard let trackId = releaseApp.trackId else {
            return
        }
        
        let schemes = ["itms-apps://", "https://"]
        
        for scheme in schemes {
            let urlString: String
            
            if let country = country, !country.isEmpty {
                urlString = "\(scheme)itunes.apple.com/\(country)/app/id\(trackId)?mt=8"
            } else {
                urlString = "\(scheme)itunes.apple.com/app/id\(trackId)?mt=8"
            }
            
            guard let url = URL(string: urlString) else { continue }
            
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:])
                return
            }
        }
    }
    
    private func getTopViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
              let rootViewController = window.rootViewController else {
            return nil
        }
        
        var topController = rootViewController
        
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        
        return topController
    }
}
