//
//  VirtualStreamType.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/14/26.
//

import Foundation
import GRDB
import SqlDsl

@CodingKeyMappable
struct VirtualStreamType: Codable, TableRecord, PersistableRecord {
    let id: Int
    let type: StreamType
    
    enum Columns {
        static let id = Column(CodingKeys.id.stringValue)
        static let type = Column(CodingKeys.type.stringValue)
    }
}
