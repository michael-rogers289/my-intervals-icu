//
//  StreamView.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/4/26.
//

import SwiftUI
import Charts

struct StreamView : View {
    
    @State private var viewModel = StreamViewModel()
    
    var body: some View {
        VStack {
            StreamLegendView(viewData: $viewModel.selectableStreamTypes)
            StreamChartView(
                viewData: viewModel.viewData,
                selectedStartIndex: $viewModel.subsectionStartIndex,
                selectedEndIndex: $viewModel.subsectionEndIndex
            )
                .aspectRatio(1.0 / 0.25, contentMode: .fill)
                .padding(.spacingMedium)
            StreamSummaryView(viewData: viewModel.streamSummaryData)
        }
    }
    
}
