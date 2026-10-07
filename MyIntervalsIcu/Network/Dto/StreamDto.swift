//
//  StreamDto.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/2/26.
//

import CodingKeysMacro
import Foundation

struct StreamDto: Codable {
    let type: String
    let name: String?
    let timeSeries: [Double?]?
    let values: [Double?]?
    let valueTypeIsArray: Bool
    let custom: Bool
    let allNull: Bool
    let anomalies: [Anomaly]?
    
    @CodingKeys(.all)
    struct Anomaly: Codable {
        let startIndex: Int
        let endIndex: Int
        let value: Int
        let valueEnd: Int
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case name
        case timeSeries = "data"
        case values = "data2"
        case valueTypeIsArray
        case custom
        case allNull
        case anomalies
    }
}
