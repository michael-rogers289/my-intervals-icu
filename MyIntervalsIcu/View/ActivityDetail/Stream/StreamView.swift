//
//  StreamView.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/4/26.
//

import SwiftUI
import Charts

struct StreamView: View {

    @State private var viewModel = StreamViewModel()
    @State private var overlayRect: CGRect?

    var body: some View {
        VStack {
            StreamLegendView(viewData: $viewModel.selectableStreamTypes)
                .padding(.top, .spacingLarge)

            VStack(alignment: .center, spacing: .spacingLarge) {
                ForEach(viewModel.viewData, id: \.streamType) { timeSeries in
                    GroupBox {
                        StreamChartView(
                            viewData: timeSeries,
                            isAreaChart: timeSeries.isAreaChart,
                        )
                        .aspectRatio(1.0 / 0.2, contentMode: .fill)
                        if let summary = viewModel.summaryViewData[timeSeries.streamType] {
                            StreamSummaryView(
                                firstViewData: summary,
                                secondViewData: viewModel.filteredSummaryViewData[summary.type]
                            )
                                .padding(.top, .spacingLarge)
                        }
                    } label: {
                        Text(timeSeries.title)
                            .padding(.bottom, .spacingLarge)
                    }
                }
            }
            .padding(.top, .spacingLarge)
        }
    }

}
