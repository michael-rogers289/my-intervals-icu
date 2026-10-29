//
//  ActivityFtpZone.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/28/26.
//

import CodingKeysMacro
import GRDB

@CodingKeys(.all)
struct ActivityFtpZone: Codable, FetchableRecord, PersistableRecord {
    var id: Int64?
    let upperValue: Double
    let activityId: String

    enum Columns {
        static let id = Column(CodingKeys.id)
        static let upperValue = Column(CodingKeys.upperValue)
        static let activityId = Column(CodingKeys.activityId)
    }
}
