//
//  HeartRateLoadType.swift
//  MyIntervalsIcu
//
//  Created by Michael Rogers on 11/9/25.
//

import CodingKeysMacro
import Foundation

enum HeartRateLoadType: String, Codable {
    case averageHeartRate = "AVG_HR"
    case heartRateZones = "HR_ZONES"
    case Hrss = "HRSS"
}
