//
//  StreamView.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/4/26.
//

import SwiftUI
import Charts

struct StreamView : View {
    
    let viewData: StreamViewData
    
    var body: some View {
        Chart(viewData.timeSeries, id: \.streamType) { timeSeries in
            ForEach(timeSeries.plottableData, id: \.self) { point in
                LineMark(
                    x: .value("Time", point.x),
                    y: .value(point.yValueTitle, point.y),
                    series: .value(point.yValueTitle, point.yValueTitle)
                ).foregroundStyle(timeSeries.streamType.color)
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
    }
    
}
