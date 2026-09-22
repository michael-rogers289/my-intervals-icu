//
//  Activity.swift
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
struct Activity: Identifiable, Codable, PersistableRecord, FetchableRecord {
    let id: String
    let startDate: Date
    let distince: Double
}
