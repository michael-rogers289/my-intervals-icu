//
//  StreamPoint.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/14/26.
//

import Foundation
import GRDB

struct StreamPoint: Codable, Equatable, TableRecord, FetchableRecord {
    let value: Double
    let order: Int
    let type: StreamType
}
