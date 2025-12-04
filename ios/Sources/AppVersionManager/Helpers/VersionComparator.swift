//
//  VersionComparator.swift
//  App
//
//  Created by   TeamCity Agent on 04.12.2025.
//

import Foundation

public class VersionComparator {
    private let currentApp: AppVersion
    private let releaseApp: AppVersion

    
    public init(currentApp: AppVersion, releaseApp: AppVersion) {
        self.currentApp = currentApp
        self.releaseApp = releaseApp
    }
    
    private func parseVersion(_ versionString: String) -> (major: Int, minor: Int, patch: Int)? {
        let components = versionString.split(separator: ".").compactMap { Int($0) }
        
        guard components.count >= 3 else {
            return nil
        }
        
        return (major: components[0], minor: components[1], patch: components[2])
    }
    
    private func compare(_ currentVersion: String, with releaseVersion: String) -> ComparisonResult {
        guard let current = parseVersion(currentVersion),
              let release = parseVersion(releaseVersion) else {
            return .orderedSame
        }
        
        if current.major < release.major {
            return .orderedAscending
        } else if current.major > release.major {
            return .orderedDescending
        }
        
        if current.minor < release.minor {
            return .orderedAscending
        } else if current.minor > release.minor {
            return .orderedDescending
        }
        
        if current.patch < release.patch {
            return .orderedAscending
        } else if current.patch > release.patch {
            return .orderedDescending
        }
        
        return .orderedSame
    }
    
    public var shouldNotify: Bool {
        let comparisonResult = compare(currentApp.version, with: releaseApp.version)
        
        let shouldNotify = comparisonResult == .orderedAscending
        
        return shouldNotify
    }
}
