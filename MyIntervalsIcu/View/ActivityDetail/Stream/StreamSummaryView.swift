//
//  StreamSummaryView.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/8/26.
//

import SwiftUI



struct StreamSummaryView : View {
    
    let viewData: [any StreamSummaryViewData]
    
    var body: some View {
        Grid {
            GridRow(alignment: .center) {
                Text("Metric")
                Text("Min")
                Text("Average")
                Text("Max")
            }.font(.title)
            
            ForEach(viewData, id: \.type) { data in
                Divider()
                GridRow(alignment: .center) {
                    Text(data.type.title)
                    data.minText
                    data.averageText
                    data.maxText
                }.font(.callout)
            }
        }
        
    }
    
}

private extension StreamSummaryViewData {
    var minText: Text {
        Text(
            min,
            format: format
        )
    }
    
    var averageText: Text {
        Text(
            average,
            format: format
        )
    }
    
    var maxText: Text {
        Text(
            max,
            format: format
        )
    }
}
