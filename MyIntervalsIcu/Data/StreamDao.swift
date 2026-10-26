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

final class StreamDao: Sendable {

    private let databaseQueue: DatabaseQueue
    private static let streamVirtualTable = Table("VirtualStreamType")

    init(databaseQueue: DatabaseQueue) {
        self.databaseQueue = databaseQueue
    }

    func store(streamTypeLinks: [StreamTypeLink]) async {
        try? await databaseQueue.write { database in
            try streamTypeLinks.insertAll(in: database)
        }
    }

    func store(streams: [Stream]) async throws {
        try await databaseQueue.write { database in
            try streams.insertAll(in: database)
        }
    }

    func observerLastSecond(for activityId: Activity.ActivityId) -> AnyPublisher<Double?, Error> {
        return ValueObservation.tracking { database in
            try Stream
                .filter { $0.activityId == activityId && $0.type == StreamType.time }
                .select({ max($0.value) }, as: Double.self)
                .fetchOne(database)
        }
        .publisher(in: databaseQueue)
        .eraseToAnyPublisher()
    }

    func observeSummaries(
        for activityId: Activity.ActivityId,
        filteringBy types: [StreamType],
        overTimeRange timeRange: Range<Int>? = nil
    ) -> AnyPublisher<[StreamSummary], Error> {
        ValueObservation.tracking { database in
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
                .filter {
                    $0.activityId == activityId &&
                    types.contains($0.type) &&
                    (timeRange?.contains($0.order) ?? true)
                }
                .group(\.type)
                .asRequest(of: StreamSummary.self)
                .fetchAll(database)
        }
        .publisher(in: databaseQueue)
        .eraseToAnyPublisher()
    }

    func observeStreams(
        for activityId: Activity.ActivityId,
        filteringBy types: [StreamType]
    ) -> AnyPublisher<[StreamType: [StreamPoint]], Error> {
        return ValueObservation.tracking { database in
            let streams = try Stream
                .filter { $0.activityId == activityId && types.contains($0.type) }
                .order { $0.order.asc }
                .asRequest(of: StreamPoint.self)
                .fetchAll(database)
            return Dictionary(grouping: streams, by: \.type)
        }
        .publisher(in: databaseQueue)
        .eraseToAnyPublisher()
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

}
