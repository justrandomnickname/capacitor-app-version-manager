//
//  UpdateNotificationScheduler.swift
//  App
//
//  Created by   TeamCity Agent on 04.12.2025.
//

import Foundation

public class UpdateNotificationScheduler {
    private let userDefaults = UserDefaults.standard
    private let lastNotificationDateKey = "AppVersionManager.lastNotificationDate"
    private let lastDismissDateKey = "AppVersionManager.lastDismissDate"
    
    private let options: NotifyNewReleaseOptions
    
    public init(_options: NotifyNewReleaseOptions) {
        self.options = _options
    }
    
    public func shouldShowNotification() -> Bool {
        switch self.options.frequency {
        case .always:
            return true
            
        case .daily:
            return shouldShowBasedOnInterval(days: 1)
            
        case .weekly:
            return shouldShowBasedOnInterval(days: 7)
            
        case .monthly:
            return shouldShowBasedOnInterval(days: 30)
        }
    }
    
    public func markNotificationShown() {
        let now = Date()
        userDefaults.set(now, forKey: lastNotificationDateKey)
    }
    
    public func markNotificationDismissed() {
        let now = Date()
        userDefaults.set(now, forKey: lastDismissDateKey)
        userDefaults.removeObject(forKey: lastNotificationDateKey)
    }
    
    public func reset() {
        userDefaults.removeObject(forKey: lastNotificationDateKey)
        userDefaults.removeObject(forKey: lastDismissDateKey)
    }
    
    public func getLastNotificationDate() -> Date? {
        return userDefaults.object(forKey: lastNotificationDateKey) as? Date
    }
    
    public func getLastDismissDate() -> Date? {
        return userDefaults.object(forKey: lastDismissDateKey) as? Date
    }
    
    public func getDebugInfo() -> [String: Any] {
        var info: [String: Any] = [
            "frequency": self.options.frequency.rawValue,
            "shouldShow": shouldShowNotification()
        ]
        
        if let lastNotification = getLastNotificationDate() {
            info["lastNotificationDate"] = lastNotification
            info["daysSinceNotification"] = Calendar.current.dateComponents([.day], from: lastNotification, to: Date()).day ?? 0
        }
        
        if let lastDismiss = getLastDismissDate() {
            info["lastDismissDate"] = lastDismiss
            info["daysSinceDismiss"] = Calendar.current.dateComponents([.day], from: lastDismiss, to: Date()).day ?? 0
        }
        
        return info
    }
    
    private func shouldShowBasedOnInterval(days: Int) -> Bool {
        if let lastDismiss = getLastDismissDate() {
            let daysSinceDismiss = Calendar.current.dateComponents([.day], from: lastDismiss, to: Date()).day ?? 0
            
            if daysSinceDismiss < days {
                return false
            }
            
            return true
            
        }
        
        guard let lastNotification = getLastNotificationDate() else {
            return true
        }
        
        let daysSinceLastNotification = Calendar.current.dateComponents([.day], from: lastNotification, to: Date()).day ?? 0
        
        let shouldShow = daysSinceLastNotification >= days
        
        return shouldShow
    }
}
