//
//  NotifyNewReleaseOptions.swift
//  App
//
//  Created by   TeamCity Agent on 04.12.2025.
//

import Foundation
import Capacitor


public enum NotificationFrequency: String {
    case always
    case daily
    case weekly
    case monthly
}

public enum CriticalUpdateType: String {
    case major
    case minor
    case patch
}


public struct NotifyNewReleaseOptions {
    let forceCountry: Bool
    let forceNotify: Bool?
    let message: String?
    let title: String?
    let buttonCloseText: String?
    let buttonUpdateText: String?
    let appStoreLink: String?
    let critical: CriticalUpdateType?
    let frequency: NotificationFrequency

    init(from jsObject: JSObject?) {
        if let frequencyString = jsObject?["frequency"] as? String,
           let freq = NotificationFrequency(rawValue: frequencyString) {
            self.frequency = freq
        } else {
            self.frequency = .always
        }

        if let criticalString = jsObject?["critical"] as? String {
            self.critical = CriticalUpdateType(rawValue: criticalString)
        } else {
            self.critical = nil
        }
        
        self.forceCountry = jsObject?["forceCountry"] as? Bool ?? true
        self.forceNotify = jsObject?["forceNotify"] as? Bool
        self.message = jsObject?["message"] as? String
        self.title = jsObject?["title"] as? String
        self.appStoreLink = jsObject?["appStoreLink"] as? String
        self.buttonCloseText = jsObject?["buttonCloseText"] as? String
        self.buttonUpdateText = jsObject?["buttonUpdateText"] as? String
    }
}


