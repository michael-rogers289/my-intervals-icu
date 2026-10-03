//
//  NetworkLogger.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 9/23/26.
//

import Foundation
import OSLog

protocol NetworkLogging : Sendable {
    
    func logResponse(
        _ response: URLResponse,
        andData data: Data?,
        of request: URLRequest,
    )
    
    func logError(
        _ error: NetworkManager.NetworkError,
        data: Data?,
        for request: URLRequest,
        and response: URLResponse?
    ) -> NetworkManager.NetworkError
    
}

struct NetworkLogger : NetworkLogging {
    
#if DEBUG
    private static let isDebuggable = true
#else
    private static let isDebuggable = false
#endif
    
    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "network")
    
    func logResponse(
        _ response: URLResponse,
        andData data: Data?,
        of request: URLRequest,
    ) {
        guard Self.isDebuggable,
              let response = response as? HTTPURLResponse else { return }
        
        let dataString: String = if let data {
            "\((try? JSONSerialization.jsonObject(with: data)) ?? "")"
        } else {
            ""
        }
                
        Self.logger.debug(
            """
            🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢🟢
            \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "") : \(response.statusCode)
            \(response.allHeaderFields.map { "\($0): \($1)" }.joined(separator: "\n"))
            \(dataString)
            ⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️
            """
        )
    }
    
    func logError(
        _ error: NetworkManager.NetworkError,
        data: Data?,
        for request: URLRequest,
        and response: URLResponse? = nil
    ) -> NetworkManager.NetworkError {
        guard Self.isDebuggable else {
            return error
        }
        
        let additionalData = switch error {
        case .cancelled: "Cancelled"
        case .unableToDecodeResponse(let decodeError): "Decode Error: \(decodeError)"
        case .unableToFetchData(let path): "Unable to fetch data for: \(path)"
        }
        
        let responseStatusCode = if let response = response as? HTTPURLResponse {
            "\(response.statusCode)"
        } else {
            "None"
        }
        
        let dataString = if let data {
            String(describing: try? JSONSerialization.jsonObject(with: data))
        } else {
            "No Response Data"
        }
        
        Self.logger.error(
            """
            🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴
            \(request.allHTTPHeaderFields?.map({ "\($0): \($1)" }).joined(separator: "\n") ?? "No Header Fields") 
            \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "") : \(responseStatusCode)
            \(additionalData)
            \(dataString)
            🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺🔺
            """
        )
        return error
    }
    
}
