//
//  Stream.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/4/26.
//

import CodingKeysMacro
import GRDB
import SqlDsl

@CodingKeyMappable
struct Stream: Codable, TableRecord, FetchableRecord, PersistableRecord {
    
    static let streamType = hasOne(
        VirtualStreamType.self,
        key: Columns.type.name,
        using: ForeignKey([Columns.type], to: [VirtualStreamType.Columns.type])
    )
    
    let id: String
    let type: StreamType
    let value: Double
    let order: Int
    let activityId: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case value
        case order
        case activityId = "activity_id"
    }
    
    enum Columns {
        static let id = Column(CodingKeys.id.rawValue)
        static let type = Column(CodingKeys.type.rawValue)
        static let value = Column(CodingKeys.value.rawValue)
        static let order = Column(CodingKeys.order.rawValue)
        static let activityId = Column(CodingKeys.activityId.rawValue)
    }
}
