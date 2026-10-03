//
//  ActivityDto.swift
//  MyIntervalsIcu
//
//  Created by Michael Rogers on 11/9/25.
//

import CodingKeysMacro
import Foundation
import SwiftProtobuf

@CodingKeys(
    .custom(
        [
            "maxHeartRate" : "max_heartrate",
            "averageHeartRate" : "average_heartrate",
            "avgLeftRightBalance" : "avg_lr_balance",
            "icuHeartRateZones" : "icu_hr_zones",
            "icuHeartRateRecovery" : "icu_hrr",
            "paceZoneTimes" : "pace_zone_times"
        ]
    )
)
struct ActivityDto: Codable {
    let id: String
    let startDateLocal: String
    let type: String?
    let icuPmCp: Int?
    let icuPmWPrime: Int?
    let icuPmPMax: Int?
    let icuPmFtp: Int?
    let icuPmFtpWatts: Int?
    let icuPmTrainingLoad: Int?
    let ssPMax: Double?
    let ssWPrime: Double?
    let ssCp: Double?
    let elapsedTime: Int?
    let icuWeightedAvgWatts: Int?
    let startDate: Date?
    let distance: Double?
    let maxSpeed: Double?
    let averageSpeed: Double?
    let deviceWatts: Bool?
    let maxHeartRate: Int?
    let averageHeartRate: Int?
    let averageCadence: Double?
    let calories: Int?
    let averageTemp: Double?
    let minTemp: Int?
    let maxTemp: Int?
    let avgLeftRightBalance: Double?
    let gear: GearDto?
    let perceivedExertion: Double?
    let created: Date?
    let pMax: Int?
    let thresholdPace: Double?
    let powerFieldNames: [String]
    let powerField: String?
    let icuZoneTimes: [PowerZoneTime]
    let icuHeartRateZones: [Int]
    let icuHrZoneTimes: [Int]
    let paceZoneTimes: [Int]?
    let polarizationIndex: Double?
    let icuHeartRateRecovery: IcuHeartRateRecovery?
    let powerLoad: Int?
    let hrLoad: Int?
    let paceLoad: Int?
    let hrLoadType: HeartRateLoadType?
    let icuPowerHr: Double?
    let icuAverageWatts: Int?
    let strainScore: Double?
    let skylineChartBytes: String
    let streamTypes: [StreamTypeDto]
}
