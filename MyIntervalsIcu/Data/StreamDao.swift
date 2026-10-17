//
//  StreamDao.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/4/26.
//

import Foundation
import Combine
import GRDB
import SqlDsl

class StreamDao {

    private let databaseQueue: DatabaseQueue
    private static let streamVirtualTable = Table("VirtualStreamType")

    init(databaseQueue: DatabaseQueue) {
        self.databaseQueue = databaseQueue
    }

    @DatabaseActor
    func store(streamTypeLinks: [StreamTypeLink]) async {
        try? await databaseQueue.write { database in
            try streamTypeLinks.insertAll(in: database)
        }
    }

    @DatabaseActor
    func store(streams: [Stream]) async {
        try? await databaseQueue.write { database in
            try streams.insertAll(in: database)
        }
    }

    func getSummaries(
        for activityId: Activity.ActivityId,
        filteringBy types: [StreamType],
        overTimeRange timeRange: Range<Int>
    ) async throws -> [StreamSummary] {
        try await databaseQueue.read { database in
            try Stream
                .select(
                    [
                        Stream.Columns.type,
                        average(Stream.Columns.value).forKey("averageIncludingZeros"),
                        SQL("AVG(NULLIF(value, 0))").forKey("averageExcludingZeros"),
                        min(Stream.Columns.value).forKey("min"),
                        max(Stream.Columns.value).forKey("max")
                    ]
                )
                .filter { $0.activityId == activityId && timeRange.contains($0.order)}
                .joining(required: Stream.streamType)
                .group(\.type)
                .asRequest(of: StreamSummary.self)
                .fetchAll(database)
        }
    }

    @DatabaseActor
    func observeSummaries(
        for activityId: Activity.ActivityId,
        filteringBy types: [StreamType]
    ) async throws -> AsyncValueObservation<[StreamSummary]> {
        try await createVirtualTable(with: types)

        return ValueObservation.tracking { database in
            try Stream
                .select(
                    [
                        Stream.Columns.type,
                        average(Stream.Columns.value).forKey("averageIncludingZeros"),
                        SQL("AVG(NULLIF(value, 0))").forKey("averageExcludingZeros"),
                        min(Stream.Columns.value).forKey("min"),
                        max(Stream.Columns.value).forKey("max")
                    ]
                )
                .filter { $0.activityId == activityId }
                .joining(required: Stream.streamType)
                .group(\.type)
                .asRequest(of: StreamSummary.self)
                .fetchAll(database)
        }.values(in: databaseQueue)
    }

    @DatabaseActor
    func observeStreams(
        for activityId: Activity.ActivityId,
        filteringBy types: [StreamType]
    ) async throws -> AsyncValueObservation<[StreamType: [StreamPoint]]> {
        try await createVirtualTable(with: types)
        return ValueObservation.tracking { database in
            let streams = try Stream
                .filter { $0.activityId == activityId }
                .joining(required: Stream.streamType)
                .order { $0.order.asc }
                .asRequest(of: StreamPoint.self)
                .fetchAll(database)
            return Dictionary(grouping: streams, by: \.type)
        }
        .values(in: databaseQueue)
    }

    func getStreamTypes(for activityId: Activity.ActivityId) -> AnyPublisher<[StreamTypeLink], Error> {
        ValueObservation.tracking { database in
            try StreamTypeLink
                .filter { $0.activityId == activityId }
                .fetchAll(database)
        }
        .publisher(in: databaseQueue)
        .eraseToAnyPublisher()
    }

    @DatabaseActor
    private func createVirtualTable(with types: [StreamType]) async throws {
        try await databaseQueue.write { database in
            if try database.tableExists(Self.streamVirtualTable.tableName) {
                try database.drop(table: Self.streamVirtualTable.tableName)
            }
            try database.create(virtualTable: Self.streamVirtualTable.tableName, using: FTS5()) {
                $0.column(VirtualStreamType.Columns.type.name)
            }
            try types
                .map { VirtualStreamType(type: $0) }
                .insertAll(in: database)
        }
    }

}
