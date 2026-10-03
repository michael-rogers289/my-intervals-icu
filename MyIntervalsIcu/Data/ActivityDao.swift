//
//  ActivityDao.swift
//  MyIntervalsIcu
//
//  Created by Michael Rogers on 11/8/25.
//

import Combine
import Foundation
import SqlDsl
import GRDB

@globalActor actor DatabaseActor {
    static let shared = DatabaseActor()
}

final class ActivityDao : Sendable {
    
    let calendarRepository: CalendarRepository
    private let databaseQueue: DatabaseQueue
        
    init(
        databaseQueue: DatabaseQueue,
        calendarRepository: CalendarRepository
    ) {
        self.calendarRepository = calendarRepository
        self.databaseQueue = databaseQueue
        do {
            try databaseQueue.createTables()
            Task {
                do {
                    try await insertStreamTypesIfNeeded()
                } catch {
                    // TODO: Should log. I don't think this should gate the rest of the app functioning
                    fatalError("Unable to insert stream types")
                }
            }
            
        } catch let error {
            fatalError("Failed to create database tables\(error)")
        }
    }
    
    @DatabaseActor
    func insertAll(
        activities: [Activity],
        heartRateZones: [ActivityHeartRateZone],
        powerZones: [ActivityPowerZone],
        summaryChartBars: [SummaryChartBar],
        streamTypeLinks: [StreamTypeLink],
    ) async {
        try? await databaseQueue.write { db in
            try activities.insertAll(in: db)
            try heartRateZones.insertAll(in: db)
            try powerZones.insertAll(in: db)
            try summaryChartBars.insertAll(in: db)
            try streamTypeLinks.insertAll(in: db)
        }
    }
        
    func getActivities(in interval: DateInterval) -> AnyPublisher<[Activity], Error> {
        ValueObservation.tracking { database in
            try Activity.fetchAll(database)
                .filter { interval.contains($0.startDate) }
                .sorted { $0.startDate > $1.startDate }
        }
        .publisher(in: databaseQueue)
        .eraseToAnyPublisher()
    }
    
    func getActivity(byId id: Activity.ActivityId) -> AnyPublisher<Activity?, Error> {
        ValueObservation.tracking { database in
            try Activity.filter(id: id).fetchOne(database)
        }
        .publisher(in: databaseQueue)
        .eraseToAnyPublisher()
    }
    
    @DatabaseActor
    func getGroupedSummaryChartBars(for activityIds: [Activity.ActivityId]) throws -> [String: [SummaryChartBar]] {
        return try databaseQueue.read { database in
            return Dictionary(
                grouping: try SummaryChartBar.filter(activityIds.contains(SummaryChartBar.Columns.activityId)).fetchAll(database),
                by: { $0.activityId }
            )
        }
    }
    
    func getTotalDistance(from start: Date, to end: Date) -> AnyPublisher<Double, Error> {
        return ValueObservation
            .tracking {
                let statement = Sql<Activity>(
                    select: Select { factory in
                        Sum(operand: factory.operand(from: \.distince)).asOther(name: "distance_sum")
                    },
                    whereClause: Where(operand: Operands.Path(keyPath: \Activity.startDate) ..< start && end)
                )
                return try Double.fetchOne($0, sql: statement.raw) ?? 0.0
            }
            .publisher(in: databaseQueue)
            .eraseToAnyPublisher()
    }
    
    func getPowerZonesGroupedByZone(
        between start: Date,
        and end: Date,
    ) -> AnyPublisher<[ZoneSummary], Error> {
        let statement = getStatement(
            between: start,
            and: end,
            zone: \ActivityPowerZone.zone,
            secondsInZone: \.secondsInZone,
            activityId: \.activityId
        )
        return valueObservation(from: statement.raw)
    }
        
    func getHeartRateZonesGroupedByZone(
        between start: Date,
        and end: Date,
    ) -> AnyPublisher<[ZoneSummary], Error> {
        let statement = getStatement(
            between: start,
            and: end,
            zone: \ActivityHeartRateZone.zone,
            secondsInZone: \.secondsInZone,
            activityId: \.activityId
        )
        return valueObservation(from: statement.raw)
    }
    
    //MARK: Private Methods
    
    @DatabaseActor
    private func insertStreamTypesIfNeeded() throws {
        let allStreamTypes = StreamType.allCases
        
        let storedStreamTypeRecordCount = try databaseQueue.read { database in
            try StreamTypeRecord.fetchCount(database)
        }
        
        guard allStreamTypes.count != storedStreamTypeRecordCount else { return }
        
        let streamTypeRecords = allStreamTypes.map {
            StreamTypeRecord(id: $0.id, name: $0)
        }
        
        try databaseQueue.write { database in
            try StreamTypeRecord.deleteAll(database)
            try streamTypeRecords.insertAll(in: database)
        }
    }
    
    private func getStatement<T>(
        between start: Date,
        and end: Date,
        zone: PartialKeyPath<T>,
        secondsInZone: PartialKeyPath<T>,
        activityId: PartialKeyPath<T>
    ) -> Sql<T> where T : Zone {
        Sql(
            select: Select { factory in
                factory.column(from: zone)
                Sum(operand: factory.operand(from: secondsInZone)).asOther(name: "sum_seconds_in_zone")
                Parentheses {
                    Sum(operand: factory.operand(from: secondsInZone)) * Operands.Raw(numeric: 100.0) /
                    Sum(operand: Sum(operand: factory.operand(from: secondsInZone))).over()
                }.asOther(name: "percentage_in_zone")
            },
            join: Join(firstTablePath: activityId, onOtherPath: \Activity.id),
            whereClause: Where(
                operand: Operands.Path(keyPath: \Activity.startDate) ..< start && end
            ),
            groupedBy: GroupBy(path: zone),
            orderdBy: OrderBy(path: zone),
        )
    }
    
    private func valueObservation(from statement: String) -> AnyPublisher<[ZoneSummary], Error> {
        ValueObservation
            .tracking {
                    try Row.fetchAll(
                        $0,
                        sql: statement
                    ).map {
                        ZoneSummary(
                            zone: $0["zone"],
                            secondsInZone: $0["sum_seconds_in_zone"],
                            percentInZone: $0["percentage_in_zone"]
                        )
                    }
            }
            .publisher(in: databaseQueue)
            .eraseToAnyPublisher()
    }
    
}
