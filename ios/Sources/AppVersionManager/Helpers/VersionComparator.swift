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
    private let criticalUpdateVersion: CriticalUpdateType?

    
    public init(currentApp: AppVersion, releaseApp: AppVersion, criticalUpdateVersion: CriticalUpdateType?) {
        self.currentApp = currentApp
        self.releaseApp = releaseApp
        self.criticalUpdateVersion = criticalUpdateVersion
    }
    
    private func parseVersion(_ versionString: String) -> (major: Int, minor: Int, patch: Int)? {
        let components = versionString.split(separator: ".").compactMap { Int($0) }
        
        if components.isEmpty {
            return nil
        }
        
        let major = components.count > 0 ? components[0] : 0
        let minor = components.count > 1 ? components[1] : 0
        let patch = components.count > 2 ? components[2] : 0
        
        return (major: major, minor: minor, patch: patch)
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
        
        let comparisonResult = self.compare(currentApp.version, with: releaseApp.version)
        
        let shouldNotify = comparisonResult == .orderedAscending
        
        return shouldNotify
    }
    
    public var isUpdateCritical: Bool {
        guard let criticalType = self.criticalUpdateVersion,
              let current = parseVersion(self.currentApp.version),
              let release = parseVersion(self.releaseApp.version) else {
            return false
        }
        
        switch criticalType {
        case .major:
            return release.major > current.major
            
        case .minor:
            if release.major > current.major { 
                return true 
            }

            return release.major == current.major && release.minor > current.minor
            
        case .patch:
            if release.major > current.major { 
                return true 
            }

            if release.major == current.major && release.minor > current.minor { 
                return true 
            }

            return release.major == current.major && release.minor == current.minor && release.patch > current.patch
        }
    }
}
