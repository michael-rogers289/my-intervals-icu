//
//  ActivityHeartRateZone.swift
//  MyIntervalsIcu
//
//  Created by Michael Rogers on 11/8/25.
//

import CodingKeysMacro
import Foundation
import GRDB
import GRDBSQLite
import SqlDsl

@CodingKeys(.all)
@CodingKeyMappable
struct ActivityHeartRateZone: Zone, Identifiable, PersistableRecord, FetchableRecord {
    typealias ZoneType = ActivityHeartRateZone
    
    let id: String
    
    /// The Heart Rate Zone Number (e.g. Zone 1, Zone 2, etc.). Will be 1-indexed and always positive.
    let zone: Int
    let lowerBound: Int
    let upperBound: Int
    let secondsInZone: Int
    let activityId: String
}
