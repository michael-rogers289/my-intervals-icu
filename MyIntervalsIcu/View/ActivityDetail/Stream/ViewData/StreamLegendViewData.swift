//
//  StreamLegendViewData.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/6/26.
//

import Foundation

struct StreamLegendViewData : Sendable {
    
    let streamType: TimeSeriesStreamType
    private(set) var isSelected: Bool
    
    init(
        streamType: TimeSeriesStreamType,
        isSelected: Bool
    ) {
        self.streamType = streamType
        self.isSelected = isSelected
    }
    
    mutating func toggle() {
        isSelected.toggle()
    }
    
}
