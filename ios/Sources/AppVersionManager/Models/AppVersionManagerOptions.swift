//
//  AppVersionManagerOptions.swift
//  App
//
//  Created by   TeamCity Agent on 02.12.2025.
//

import Foundation
import Capacitor

public struct AppVersionManagerOptions {
    let forceCountry: Bool
    
    init() {
        self.forceCountry = false
    }
    
    init(from jsObject: JSObject?) {
        self.forceCountry = jsObject?["forceCountry"] as? Bool ?? false
    }
}
