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
import SwiftProtobuf

@CodingKeys(.all)
@CodingKeyMappable
struct Activity: Identifiable, Codable, PersistableRecord, FetchableRecord {
    let id: String
    let startDate: Date
    let distince: Double
    let elapsedTime: Int?
    let type: String?
    let averageCadence: Double?
    let calories: Int?
    let polarizationIndex: Double?
    
    // MARK: Speed
    let maxSpeed: Double?
    let averageSpeed: Double?
    
    // MARK: Watts
    let normalizedWatts: Int?
    let icuAverageWatts: Int?
    let deviceWatts: Bool?
    
    // MARK: Heart Rate
    let maxHeartRate: Int?
    let averageHeartRate: Int?
}
