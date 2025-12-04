//
//  CountryHelper.swift
//  App
//
//

import Foundation

public class CountryHelper {
    private let _countryCode: String?
    private let _options: AppVersionManagerOptions?
    
    public init(country: String?, options: AppVersionManagerOptions?) {
        self._options = options
        self._countryCode = country
    }
    
    public var countryCode: String? {
        let forceCountry = _options?.forceCountry ?? true
        
        if forceCountry {
            if let country = _countryCode, !country.isEmpty {
                return country.lowercased()
            }
            
            return getCountryCodeFromLocale()
        } else {
            if let localeCountry = getCountryCodeFromLocale() {
                return localeCountry
            }
            
            if let country = _countryCode, !country.isEmpty {
                return country.lowercased()
            }
            
            return nil
        }
    }
    
    private func getCountryCodeFromLocale() -> String? {
        guard let countryCode = Locale.current.regionCode else {
            return nil
        }
        
        return countryCode.lowercased()
    }
}
