//
//  HistogramDto.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 9/23/26.
//

import Foundation
import ReerCodable

@Codable
struct HistogramDto {
    let start: Int
    let secs: Int
    let movingSecs: Int
    let watts: Double
    @CodingKey("hr")
    let heartRate: Double
    let cadence: Int
}
