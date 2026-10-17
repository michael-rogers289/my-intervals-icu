//
//  StreamSummary.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/12/26.
//

import CodingKeysMacro
import GRDB

struct StreamSummary: Codable, FetchableRecord {

    let type: StreamType
    let min: Double
    let max: Double
    let averageIncludingZeros: Double
    let averageExcludingZeros: Double

}
