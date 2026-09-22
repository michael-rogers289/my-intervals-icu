//
//  PowerZoneTime.swift
//  MyIntervalsIcu
//
//  Created by Michael Rogers on 11/9/25.
//

import CodingKeysMacro
import Foundation

@CodingKeys(.custom(["timeInZone" : "secs"]))
struct PowerZoneTime: Codable {
    let id: String
    /**
     * Time in seconds spent in this zone
     */
    let timeInZone: Int
}
