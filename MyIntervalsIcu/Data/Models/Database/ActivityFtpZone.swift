//
//  ActivityFtpZone.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/28/26.
//

import CodingKeysMacro
import GRDB

@CodingKeys(.all)
struct ActivityFtpZone: Codable, FetchableRecord, PersistableRecord, TableRecord {
    var id: Int64?
    let upperValue: Double
    let activityId: String

    enum Columns {
        static let id = Column(CodingKeys.id.rawValue)
        static let upperValue = Column(CodingKeys.upperValue.rawValue)
        static let activityId = Column(CodingKeys.activityId.rawValue)
    }
}

extension ActivityFtpZone: MutablePersistableRecord {

    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }

}
