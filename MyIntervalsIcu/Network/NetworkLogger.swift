//
//  NetworkLogger.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 9/23/26.
//

import Foundation
import OSLog

protocol NetworkLogging {
    
    func logResponse<T>(
        _ response: URLResponse,
        andData data: T?,
        of request: URLRequest,
    )
    
}

struct NetworkLogger : NetworkLogging {
    
#if DEBUG
    private static let isDebuggable = true
#else
    private static let isDebuggable = false
#endif
    
    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "", category: "network")
    
    func logResponse<T>(
        _ response: URLResponse,
        andData data: T?,
        of request: URLRequest,
    ) {
        guard Self.isDebuggable,
              let response = response as? HTTPURLResponse else { return }
        
        let dataString: String = if let data = data as? Array<Any> {
            if data.isEmpty {
                "[]"
            } else {
                """
                [
                \(data.map { "\($0)" }.joined(separator: ",\n"))
                ]
                """
            }
        } else if let data {
            "\(data)"
        } else {
            ""
        }
                
        Self.logger.debug(
            """
            \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "") : \(response.statusCode)
            \(response.allHeaderFields.map { "\($0): \($1)" }.joined(separator: "\n"))
            \(dataString)
            """
        )
    }
    
}
