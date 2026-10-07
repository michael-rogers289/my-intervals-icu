//
//  ActivityRepository.swift
//  MyIntervalsIcu
//
//  Created by Michael Rogers on 11/11/25.
//

import Combine
import Foundation
import GRDB

class ActivityRepository {
    
    private let activityDao: ActivityDao
    private let streamDao: StreamDao
    private let networkManager: NetworkManager
    private let calendarRepository: CalendarRepository
    
    init(
        activityDao: ActivityDao,
        streamDao: StreamDao,
        networkManager: NetworkManager,
        calendarRepository: CalendarRepository,
    ) {
        self.activityDao = activityDao
        self.streamDao = streamDao
        self.networkManager = networkManager
        self.calendarRepository = calendarRepository
    }
    
    func getActivities(for range: DateInterval) -> AnyPublisher<[Activity], Error> {
        activityDao.getActivities(in: range)
    }
    
    func getGroupedSummaryChartBars(for activities: [Activity]) async throws -> [String: [SummaryChartBar]] {
        try await activityDao.getGroupedSummaryChartBars(for: activities.map { $0.id })
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
    
    func getActivity(byId activityId: Activity.ActivityId) -> AnyPublisher<Activity?, Error> {
        activityDao.getActivity(byId: activityId)
    }
    
    func fetchActivitiesForDateRange(range: DateInterval) async throws {
        let activities = try await networkManager.getActivities(for: range)
        await activityDao.insertAll(
            activities: activities.compactMap {
                $0.mapToActivity { elapsedTime, startDate in
                    let elapsedTime = elapsedTime ?? 0
                    return calendarRepository.date(byAddingSeconds: elapsedTime, to: startDate) ?? startDate
                }
            },
            heartRateZones: activities.flatMap { $0.mapToHeartRateZones() },
            powerZones: activities.flatMap { $0.mapToPowerZones() },
            summaryChartBars: activities.flatMap { $0.mapToSummaryChartBars() },
        )
        
        let streamTypes = activities.flatMap { activity in
            activity.streamTypes.map { dto in
                dto.mapToStreamTypeLink(with: activity)
            }
        }
        await streamDao.store(streamTypeLinks: streamTypes)
    }
}
