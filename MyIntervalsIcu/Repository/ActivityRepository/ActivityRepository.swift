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
    
    
    
    /**
            Fetches the weekly heart as an observation from the local cache as well as refreshes the curent date range.
     */
    func getHeartRateZonesGroupedByZone(for currentWeekRange: DateInterval) -> AnyPublisher<[ZoneSummary], Error> {
        activityDao.getHeartRateZonesGroupedByZone(between: currentWeekRange.start, and: currentWeekRange.end)
    }
    
    func getPowerZonesGroupedByZone(for currentWeekRange: DateInterval) -> AnyPublisher<[ZoneSummary], Error> {
        activityDao.getPowerZonesGroupedByZone(between: currentWeekRange.start, and: currentWeekRange.end)
    }
    
    func getDistanceSummaryByDayBetween(for currentWeekRange: DateInterval) -> AnyPublisher<Double, Error> {
        activityDao.getTotalDistance(from: currentWeekRange.start, to: currentWeekRange.end)
    }
    
    func fetchActivitiesForDateRange(range: DateInterval) async throws {
        do {
            let dao = activityDao
            let activities = try await networkManager.getActivities(for: range)
            await dao.insertAll(
                activities: activities.compactMap { $0.mapToActivity() },
                heartRateZones: activities.flatMap { $0.mapToHeartRateZones() },
                powerZones: activities.flatMap { $0.mapToPowerZones() }
            )
        } catch {
            print("ActivityRepository", "\(error)")
        }
    }
}
