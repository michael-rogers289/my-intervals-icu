//
//  NetworkManager+Activities.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 9/24/26.
//

import Foundation

extension NetworkManager {
    
    private enum Constant {
        static let activitiesPath = "activities"
        static let powerHistogram = "power-histogram"
        static let oldestActivityQueryKey = "oldest"
        static let newestActivityQueryKey = "newest"
    }
    
    func getActivities(for dateRange: DateInterval) async throws(NetworkError) -> [ActivityDto] {
        let oldestQueryItem = URLQueryItem(
            name: Constant.oldestActivityQueryKey,
            value: calendarRepository.iso8601Format(dateRange.start)
        )
        let newestQueryItem = URLQueryItem(
            name: Constant.newestActivityQueryKey,
            value: calendarRepository.iso8601Format(dateRange.end)
        )
        let request = NetworkRequestBuilder.makeAthleteRequest(
            appendingPath: Constant.activitiesPath,
            addingQueryParameters: [oldestQueryItem, newestQueryItem]
        )
        return try await fetchAndDecode(with: request)
    }
        
}
