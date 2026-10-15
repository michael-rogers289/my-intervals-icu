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
                        average(Stream.Columns.value).forKey("average"),
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
            let sql = Sql<Stream>(
                select: Select { factory in
                    factory.column(from: \.activityId)
                    factory.column(from: \.type)
                    factory.column(from: \.order)
                    Parentheses {
                        factory.operand(from: \.value) *
                        Max(operand: factory.operand(from: \.value)).over(partition: Partition(keyPath: \Stream.activityId)) /
                            Max(operand: factory.operand(from: \.value)).over(partition: Partition(keyPath: \Stream.type))
                    }
                    .asOther(name: "value")
                    
                },
                join: Join(firstTablePath: \.type, onOtherPath: \VirtualStreamType.type),
                whereClause: Where(operand: Operands.Path(keyPath: \Stream.activityId) == activityId),
                orderdBy: OrderBy(path: \.order)
            ).raw
            
            let streams = try Row.fetchAll(
                database,
                sql: sql
            ).map {
                return StreamPoint(value: $0["value"], order: $0["order"], type: $0["type"])
            }
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
                $0.column(VirtualStreamType.Columns.id.name)
                $0.column(VirtualStreamType.Columns.type.name)
            }
            try types
                .enumerated()
                .map { VirtualStreamType(id: $0, type: $1) }
                .insertAll(in: database)
        }
    }
    
}

struct StreamPoint: Codable, TableRecord, FetchableRecord {
    let value: Double
    let order: Int
    let type: StreamType
}

@CodingKeyMappable
struct VirtualStreamType: Codable, TableRecord, PersistableRecord {
    let id: Int
    let type: StreamType
    
    enum Columns {
        static let id = Column(CodingKeys.id.stringValue)
        static let type = Column(CodingKeys.type.stringValue)
    }
}
