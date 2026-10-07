//
//  StreamView.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/4/26.
//

import SwiftUI
import Charts

struct StreamView : View {
    
    @State private var startIndex: Int?
    @State private var endIndex: Int?
    
    @State private var overlayRect: CGRect?
    
    let viewData: StreamViewData
    
    var body: some View {
        Chart {
            if let areaSeries = viewData.areaTimeSeries {
                ForEach(areaSeries.plottableData, id: \.self) { point in
                    AreaMark(
                        x: .value("Time", point.x),
                        y: .value(point.yValueTitle, point.y),
                        series: .value(point.yValueTitle, point.yValueTitle)
                    ).foregroundStyle(areaSeries.streamType.color)
                }
            }
            
            ForEach(viewData.timeSeries, id: \.streamType) { timeSeries in
                ForEach(timeSeries.plottableData, id: \.self) { point in
                    LineMark(
                        x: .value("Time", point.x),
                        y: .value(point.yValueTitle, point.y),
                        series: .value(point.yValueTitle, point.yValueTitle)
                    ).foregroundStyle(timeSeries.streamType.color)
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: [0, viewData.xMax]) { value in
                AxisGridLine().foregroundStyle(.clear) // no vertical grids
                AxisTick()
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic)
        }
        .chartOverlay { chartProxy in
            GeometryReader { geometryProxy in
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
                
                // Handle drag
                Rectangle()
                    .fill(.primary.opacity(0.01))
                    .containerShape(.rect)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                guard let plotFrame = chartProxy.plotFrame else {
                                    return
                                }
                                
                                let frame = geometryProxy[plotFrame]
                                let startX = frame.origin.x
                                let currentX = value.location.x - startX
                                
                                let originX = overlayRect?.origin.x ?? value.location.x
                                let width = value.location.x - originX
                            
                                overlayRect = CGRect(
                                    x: originX,
                                    y: frame.origin.y,
                                    width: width,
                                    height: frame.height
                                    )
                                
                                guard let index: Int = chartProxy.value(atX: currentX) else {
                                    return
                                }
                                
                                if startIndex == nil {
                                    startIndex = index
                                } else {
                                    endIndex = index
                                }
                            }
                    )
                
            }
            .onTapGesture {
                startIndex = nil
                endIndex = nil
                overlayRect = nil
            }
        }
    }
    
}
