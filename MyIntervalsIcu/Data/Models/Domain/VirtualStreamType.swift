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
    let type: StreamType

    enum Columns {
        static let type = Column(CodingKeys.type.stringValue)
    }
}
