//
//  StreamViewData.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/4/26.
//

import Foundation

struct StreamViewData {
    
    struct Point : Equatable, Hashable {
        let yValueTitle: String
        
        let x: Int
        let y: Int
    }
    
    let streamType: StreamType
    let timeSeriesData: [Point]
    
}
