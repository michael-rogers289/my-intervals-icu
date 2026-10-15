//
//  StreamViewData.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/4/26.
//

import SwiftUI

struct StreamViewData {
    
    struct Point : Equatable, Hashable {
        let yValueTitle: String
        
        let x: Double
        let y: Double
    }
    
    struct TimeSeries {
        let streamType: TimeSeriesStreamType
        let plottableData: [Point]
    }
    
    let timeSeries: [TimeSeries]
    let areaTimeSeries: TimeSeries?
    let xMax: Double
    
}
