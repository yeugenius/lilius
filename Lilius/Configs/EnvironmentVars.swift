
//
//  Environment.swift
//  Lilius
//
//  Created by Satendra Singh on 02/03/25.
//

import Foundation

public enum EnvironmentVars{
    enum Keys {
        static let itunesApiKey = "ITUNES_SECRET"
        static let baseUrl = "BASE_URL"
    }
    ///Getting plist here
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("plist file not found" )
        }
        return dict
    }( )
    ///Get apiKey and baseurl from plist
    static let baseURL: String = {
        guard let baseURLString = EnvironmentVars.infoDictionary[Keys.baseUrl]
                as? String else {
            fatalError("Base URL not set in plist")
        }
        return baseURLString
    } ()
    
    static let itunesApiKey: String = {
        return "yourItunesApiKey"
//        guard let apiKeyString = EnvironmentVars.infoDictionary[Keys.itunesApiKey]
//                as? String else {
//            fatalError("API Key not set in plist")
//        }
//        return apiKeyString
    }()
}

