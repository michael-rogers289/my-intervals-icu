//
//  StreamChartView.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/8/26.
//

import Charts
import FactoryKit
import SwiftUI

struct StreamChartView: View {

    @State private var selectionViewmModel: SelectionViewModel = Container.shared.activityDetailViewModel.resolve()
    private let viewData: StreamViewData.TimeSeries
    private let isAreaChart: Bool

    init(
        viewData: StreamViewData.TimeSeries,
        isAreaChart: Bool,
    ) {
        self.viewData = viewData
        self.isAreaChart = isAreaChart
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
                GeometryReader { geometryProxy in
                    if let plotContainerFrameAnchor = chartProxy.plotFrame {
                        let plotContainerFrame = geometryProxy[plotContainerFrameAnchor]

                        HorizontalPanGesture {
                            Rectangle()
                                .fill(.clear)
                                .contentShape(.rect)
                        } onChanged: { translation in
                            let updatedLocation = translation / plotContainerFrame.width

                            if selectionViewmModel.lowerSelectionRangeAsPercent == nil {
                                selectionViewmModel.lowerSelectionRangeAsPercent = updatedLocation
                            } else {
                                selectionViewmModel.upperSelectionRangeAsPercent = updatedLocation
                            }
                        }

                        if let upperRange = selectionViewmModel.upperSelectionRangeAsPercent,
                           let lowerRange = selectionViewmModel.lowerSelectionRangeAsPercent {
                            let upperLocation = upperRange * plotContainerFrame.width
                            let lowerLocation = lowerRange * plotContainerFrame.width
                            let width = upperLocation - lowerLocation

                            Rectangle()
                                .fill(.gray.opacity(0.3))
                                .containerShape(.rect)
                                .frame(
                                    width: width,
                                    height: plotContainerFrame.height
                                )
                                .position(
                                    x: lowerLocation + width / 2.0,
                                    y: plotContainerFrame.midY
                                )
                        }
                    }
                }
            }
            .onTapGesture {
                selectionViewmModel.resetSelectionRange()
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
