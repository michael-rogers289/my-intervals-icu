//
//  Stream.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/4/26.
//

import Foundation

struct Stream {
    let type: StreamType
    let timeSeries: [Double]
    let secondaryValues: [Double]
    let anomalies: [Anomaly]
    
    struct Anomaly {
        let startIndex: Int
        let endIndex: Int
        let value: Int
        let valueEnd: Int
    }
}
