//
//  StreamChartView.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/8/26.
//

import Charts
import SwiftUI

struct StreamChartView: View {

    private let viewData: StreamViewData.TimeSeries
    private let isAreaChart: Bool
    @Binding private var overlayRect: CGRect?

    init(
        viewData: StreamViewData.TimeSeries,
        isAreaChart: Bool,
        overlayRect: Binding<CGRect?>
    ) {
        self.viewData = viewData
        self.isAreaChart = isAreaChart
        self._overlayRect = overlayRect
    }

    var body: some View {
        StreamChartViewChart(viewData: viewData, isAreaChart: isAreaChart)
            .chartXAxis {
                let xMax = viewData.plottableData.last?.x ?? .zero
                AxisMarks(values: [Double.zero, xMax]) { _ in
                    AxisGridLine().foregroundStyle(.clear) // no vertical grids
                    AxisTick()
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic)
            }
            .chartOverlay { chartProxy in
                HorizontalPanGesture {
                    Rectangle()
                        .fill(.clear)
                        .contentShape(.rect)
                } onChanged: { frame in
                    overlayRect = frame

                    guard let index: Int = chartProxy.value(atX: frame.origin.x + frame.width) else {
                        return
                    }

//                        if selectedStartIndex == nil {
//                            selectedStartIndex = index
//                        } else {
//                            selectedEndIndex = index
//                        }
                }

                if let overlayRect {
                    Rectangle()
                        .fill(.gray.opacity(0.3))
                        .containerShape(.rect)
                        .frame(
                            width: overlayRect.width,
                            height: overlayRect.height
                        )
                        .position(
                            x: overlayRect.midX,
                            y: overlayRect.midY
                        )
                }
            }
            .onTapGesture {
//                selectedStartIndex = nil
//                selectedEndIndex = nil
                overlayRect = nil
            }
    }
}

struct StreamChartViewChart: View {

    private let viewData: StreamViewData.TimeSeries
    private let isAreaChart: Bool

    init(viewData: StreamViewData.TimeSeries, isAreaChart: Bool) {
        self.viewData = viewData
        self.isAreaChart = isAreaChart
    }

    var body: some View {
        Chart {
            if isAreaChart {
                AreaPlot(
                    viewData.plottableData,
                    x: .value("Time", \.x),
                    y: .value(viewData.streamType.title, \.y)
                ).foregroundStyle(viewData.streamType.color.opacity(0.5))
            } else {
                LinePlot(
                    viewData.plottableData,
                    x: .value("Time", \.x),
                    y: .value(viewData.streamType.title, \.y)
                ).foregroundStyle(viewData.streamType.color)
            }
        }
    }
}
