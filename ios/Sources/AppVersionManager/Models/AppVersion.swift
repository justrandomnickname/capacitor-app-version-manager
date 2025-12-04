//
//  AppVersion.swift
//  App
//
//  Created by   TeamCity Agent on 02.12.2025.
//

import Foundation


public struct AppVersion {
    let version: String  // ex. "1.0.0"
    let buildNumber: String   // ex. "42"
    public let trackId: Int? 
    
    var fullVersion: String {
        return "\(version) (\(buildNumber))" // ex. "1.0.0 (42)"
    }

    public init(version: String, buildNumber: String, trackId: Int? = nil) {
        self.version = version
        self.buildNumber = buildNumber
        self.trackId = trackId
    }
}
