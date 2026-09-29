//
//  ActivityPowerZone.swift
//  MyIntervalsIcu
//
//  Created by Michael Rogers on 11/8/25.
//

import CodingKeysMacro
import Foundation
import GRDB
import SqlDsl

@CodingKeys(.all)
@CodingKeyMappable
struct ActivityPowerZone: Zone, Identifiable, PersistableRecord, FetchableRecord {
    
    let id: String
    let zone: Int
    let secondsInZone: Int
    let activityId: String
    
}
