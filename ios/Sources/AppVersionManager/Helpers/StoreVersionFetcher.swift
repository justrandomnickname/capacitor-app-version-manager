//
//  StoreVersionFetcher.swift
//  App
//
//  Created by   TeamCity Agent on 02.12.2025.
//

import Foundation

public class StoreVersionFetcher {
    
    public func getReleaseAppVersion(
        country: String? = nil,
        bundleId: String? = nil,
        options: AppVersionManagerOptions?,
        completion: @escaping (AppVersion?) -> Void
    ) {
        let finalOptions = options ?? AppVersionManagerOptions()
        let finalBundleId = bundleId ?? getBundleIdentifier()
        
        guard let bundleId = finalBundleId else {
            completion(nil)
            return
        }
        
        guard let url = buildItunesURL(bundleId: bundleId, country: country, options: finalOptions) else {
            completion(nil)
            return
        }
        
        performRequest(url: url, completion: completion)
    }
    
    private func getBundleIdentifier() -> String? {
        return Bundle.main.bundleIdentifier
    }
    
    private func buildItunesURL(
        bundleId: String,
        country: String?,
        options: AppVersionManagerOptions
    ) -> URL? {
        var urlString = "https://itunes.apple.com/lookup?bundleId=\(bundleId)"
        
        let countryHelper = CountryHelper(country: country, options: options)
        
        if let finalCountry = countryHelper.countryCode, !finalCountry.isEmpty {
            urlString += "&country=\(finalCountry)"
        }
        
        return URL(string: urlString)
    }
    
    private func performRequest(url: URL, completion: @escaping (AppVersion?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else {
                completion(nil)
                return
            }
            
            if error != nil {
                completion(nil)
                return
            }
            
            guard let data = data else {
                completion(nil)
                return
            }
            
            let appVersion = self.parseItunesResponse(data: data)
            completion(appVersion)
        }
        
        task.resume()
    }
    
    private func parseItunesResponse(data: Data) -> AppVersion? {
        do {
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                return nil
            }
            
            guard let results = json["results"] as? [[String: Any]], !results.isEmpty else {
                return nil
            }
            
            guard let firstResult = results.first else {
                return nil
            }
            
            return createAppVersion(from: firstResult)
            
        } catch {
            return nil
        }
    }
    
    private func createAppVersion(from json: [String: Any]) -> AppVersion? {
        let version = json["version"] as? String ?? "0.0.0"
        let buildNumber = "0"
        let trackId = json["trackId"] as? Int
        
        return AppVersion(
            version: version,
            buildNumber: buildNumber,
            trackId: trackId
        )
    }
}
