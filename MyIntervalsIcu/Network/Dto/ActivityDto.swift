//
//  ActivityDto.swift
//  MyIntervalsIcu
//
//  Created by Michael Rogers on 11/9/25.
//

import Foundation
import ReerCodable

@Codable
@SnakeCase
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
    @DateCoding(.iso8601)
    let startDate: Date?
    let distance: Double?
    let maxSpeed: Double?
    let averageSpeed: Double?
    let deviceWatts: Bool?
    @CodingKey("max_heartrate")
    let maxHeartRate: Int?
    @CodingKey("average_heartrate")
    let averageHeartRate: Int?
    let averageCadence: Double?
    let calories: Int?
    let averageTemp: Double?
    let minTemp: Int?
    let maxTemp: Int?
    @CodingKey("avg_lr_balance")
    let avgLeftRightBalance: Double?
    let gear: GearDto?
    let perceivedExertion: Double?
    @DateCoding(.iso8601)
    let created: Date?
    let pMax: Int?
    let thresholdPace: Double?
    let powerFieldNames: [String]
    let powerField: String?
    let icuZoneTimes: [PowerZoneTime]
    @CodingKey("icu_hr_zones")
    let icuHeartRateZones: [Int]
    let icuHrZoneTimes: [Int]
    @CustomCoding<[Int]>(decode: { decoder in
        (try? decoder.value(forKeys: "pace_zone_times")) ?? []
    }
    )
    let paceZoneTimes: [Int]
    let polarizationIndex: Double?
    @CodingKey("icu_hrr")
    let icuHeartRateRecovery: IcuHeartRateRecovery?
    let powerLoad: Int?
    let hrLoad: Int?
    let paceLoad: Int?
    let hrLoadType: HeartRateLoadType?
    let icuPowerHr: Double?
    let icuAverageWatts: Int?
    let strainScore: Double?
}
