//
//  SummaryChartBar.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 9/28/26.
//

import CodingKeysMacro
import Foundation
import GRDB
import SqlDsl

@CodingKeys(.all)
@CodingKeyMappable
struct SummaryChartBar: Codable, TableRecord, PersistableRecord, FetchableRecord {
    let id: String
    let xChartPosition: Int
    let width: Int
    let intensity: Int
    let zone: Int
    let totalNumZones: Int
    let activityId: String
    
    enum Columns {
        static let activityId = Column(CodingKeys.activityId)
    }
}
