//
//  NetworkSession.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 9/23/26.
//

import Foundation

protocol NetworkSession {
    
    func data(for: URLRequest) async throws -> (Data, URLResponse)
    
}

extension URLSession : NetworkSession { }
