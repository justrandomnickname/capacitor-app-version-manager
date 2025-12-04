//
//  VersionHelper.swift
//  App
//
//  Created by   TeamCity Agent on 02.12.2025.
//

import Foundation

public class VersionHelper {
    
    private func getCFBundleShortVersionString() -> String? {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    private func getCFBundleVersion() -> String? {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    }
    
    public func getCurrentAppVersion() -> AppVersion? {
        guard let currentAppVersion = self.getCFBundleShortVersionString() else {
            return nil
        }
        
        guard let buildNumber = self.getCFBundleVersion() else {
            return nil
        }
        
        
        return AppVersion(
            version: currentAppVersion,
            buildNumber: buildNumber
        )
    }
}

