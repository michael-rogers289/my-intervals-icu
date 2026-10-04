//
//  NetworkManager+Streams.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/2/26.
//

import Foundation

extension NetworkManager {
     
    func get(streams: [StreamType], forId activityId: Activity.ActivityId) async throws -> [StreamDto] {
        let request = NetworkRequestBuilder.makeActivityRequest(
            activityId: activityId,
            appendingPath: "streamsjson",
            addingQueryParameters: URLQueryItem(name: "types", value: streams.map { $0.rawValue }.joined(separator: ","))
        )
        return try await self.fetchAndDecode(with: request)
    }
    
}
