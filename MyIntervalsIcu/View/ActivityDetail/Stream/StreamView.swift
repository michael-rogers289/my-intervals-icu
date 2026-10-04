//
//  StreamView.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/4/26.
//

import SwiftUI
import Charts

struct StreamView : View {
    
    @State private var viewModel: StreamViewModel
    
    init(activityId: String) {
        self.viewModel = StreamViewModel(activityId: activityId)
    }
    
    var body: some View {
        Chart {
            ForEach(viewModel.selectedActivityStreams, id: \.streamType) { viewData in
                ForEach(viewData.timeSeriesData, id: \.self) { data in
                    LineMark(
                        x: .value("Time", data.x),
                        y: .value("Value", data.yValueTitle)
                    )
                }
            }
        }
    }
    
}
