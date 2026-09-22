//
//  NetworkConstants.swift
//  MyIntervalsIcu
//
//  Created by Michael Rogers on 11/9/25.
//

import Foundation

nonisolated
struct NetworkConstants : Sendable {
    
    private enum Constant {
        static let configurationKey = "Configuration"
        static let athleteId = "ATHLETE_ID"
        static let apiKey = "API_KEY"
    }
    
    let athleteId: String
    let apiKey: String
    let authHeaderValue: String
    let baseUrl: URL
    
    init() {
        guard let athleteId = Bundle.main.getValue(forConfigurationKey: Constant.athleteId) else {
            fatalError("ERROR: Info.plist MUST contain a valid ATHLETE_ID")
        }
        self.athleteId = athleteId
        
        guard let apiKey = Bundle.main.getValue(forConfigurationKey: Constant.apiKey) else {
            fatalError("ERROR: Info.plist MUST contain a valid API_KEY")
        }
        self.apiKey = apiKey
        
        authHeaderValue = "Basic \(Data("API_KEY:\(apiKey)".utf8).base64EncodedString())"
        
        guard let baseUrl = URL(string: "https://intervals.icu/api/v1/athlete/") else {
            fatalError("invalid base url")
        }
        self.baseUrl = baseUrl
    }
    
}

private extension Bundle {
    nonisolated
    func getValue(forConfigurationKey key: String) -> String? {
        (object(forInfoDictionaryKey: "Configuration") as? [String: Any])?[key] as? String
    }
}
