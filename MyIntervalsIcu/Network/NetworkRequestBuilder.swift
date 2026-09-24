//
//  NetworkRequestBuilder.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 9/23/26.
//

import Foundation

struct NetworkRequestBuilder {
        
    private let networkConstants = NetworkConstants()
    
    func makeAthleteRequest(
        appendingPath pathToAppend: String? = nil,
        addingQueryParameters queryParameters: [URLQueryItem] = [],
        shouldAppendAthleteId: Bool = true
    ) -> URLRequest {
        let baseUrl = if (shouldAppendAthleteId) {
            networkConstants.athleteUrl.appending(path: networkConstants.athleteId)
        } else {
            networkConstants.athleteUrl
        }
        
        var url = if let pathToAppend {
            baseUrl.appendingPathComponent(pathToAppend)
        } else {
            baseUrl
        }
        
        url.append(queryItems: queryParameters)
        
        var request = URLRequest(url: url)
        setHeaders(on: &request)
        return request
    }
    
    func makeActivityRequest(
        activityId: String,
        appendingPath pathToAppend: String? = nil,
        addingQueryParameters queryParameters: [URLQueryItem] = [],
    ) -> URLRequest {
        let baseUrl = networkConstants.activityUrl.appendingPathComponent(activityId)
        
        var url = if let pathToAppend {
            baseUrl.appendingPathComponent(pathToAppend)
        } else {
            baseUrl
        }
        
        url.append(queryItems: queryParameters)
        
        var request = URLRequest(url: url)
        setHeaders(on: &request)
        return request
    }
    
    private func setHeaders(on request: inout URLRequest) {
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(networkConstants.authHeaderValue, forHTTPHeaderField: "Authorization")
    }
    
}
