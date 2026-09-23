//
//  ActivityRepository.swift
//  MyIntervalsIcu
//
//  Created by Michael Rogers on 11/11/25.
//

import Blade
import Combine
import Foundation
import GRDB

class ActivityRepository {
    
    private let activityDao: ActivityDao
    private let networkManager: NetworkManager
    
    @Provider
    init(activityDao: ActivityDao, networkManager: NetworkManager) {
        self.activityDao = activityDao
        self.networkManager = networkManager
    }
    
    func getActivities(for range: DateInterval) -> AnyPublisher<[Activity], Error> {
        activityDao.getActivities(in: range)
    }
    
    func getHeartRateZonesGroupedByZone(for range: DateInterval) -> AnyPublisher<[ZoneSummary], Error> {
        activityDao.getHeartRateZonesGroupedByZone(between: range.start, and: range.end)
    }
    
    func getPowerZonesGroupedByZone(for range: DateInterval) -> AnyPublisher<[ZoneSummary], Error> {
        activityDao.getPowerZonesGroupedByZone(between: range.start, and: range.end)
    }
    
    func getDistanceSummaryByDayBetween(for range: DateInterval) -> AnyPublisher<Double, Error> {
        activityDao.getTotalDistance(from: range.start, to: range.end)
    }
    
    func fetchActivitiesForDateRange(range: DateInterval) async throws {
        let dao = activityDao
        let activities = try await networkManager.getActivities(for: range)
        await dao.insertAll(
            activities: activities.compactMap { $0.mapToActivity() },
            heartRateZones: activities.flatMap { $0.mapToHeartRateZones() },
            powerZones: activities.flatMap { $0.mapToPowerZones() }
        )
    }
}
