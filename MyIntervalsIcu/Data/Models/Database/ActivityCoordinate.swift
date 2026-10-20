//
//  ActivityCoordinate.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/20/26.
//

import CodingKeysMacro
import GRDB

@CodingKeys(.all)
struct ActivityCoordinate: Codable, TableRecord, FetchableRecord, PersistableRecord {

    let id: String
    let activityId: String
    let latitude: Double?
    let longitude: Double?
    let order: Int

    enum Columns {
        static let id = Column(CodingKeys.id.rawValue)
        static let activityId = Column(CodingKeys.activityId.rawValue)
        static let latitude = Column(CodingKeys.latitude.rawValue)
        static let longitude = Column(CodingKeys.longitude.rawValue)
        static let order = Column(CodingKeys.order.rawValue)
    }

}
