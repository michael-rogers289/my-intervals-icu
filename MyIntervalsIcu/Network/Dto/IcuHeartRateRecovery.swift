//
//  IcuHeartRateRecovery.swift
//  MyIntervalsIcu
//
//  Created by Michael Rogers on 11/9/25.
//

import CodingKeysMacro
import Foundation

@CodingKeys(.all)
struct IcuHeartRateRecovery : Codable {
    let startIndex: Int
    let endIndex: Int
    let startTime: Int
    let endTime: Int
    let startBpm: Int
    let endBpm: Int
    let averageWatts: Int?
    let hrr: Int
}
