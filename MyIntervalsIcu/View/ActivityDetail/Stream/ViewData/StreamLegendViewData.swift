//
//  StreamLegendViewData.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/6/26.
//

import Foundation

@Observable
class StreamLegendViewData {
    
    let streamType: StreamViewData.TimeSeriesStreamType
    private(set) var isSelected: Bool
    
    init(
        streamType: StreamViewData.TimeSeriesStreamType,
        isSelected: Bool
    ) {
        self.streamType = streamType
        self.isSelected = isSelected
    }
    
    func toggle() {
        isSelected.toggle()
    }
    
}
