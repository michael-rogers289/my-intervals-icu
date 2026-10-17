//
//  StreamSummaryView.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/8/26.
//

import SwiftUI

struct StreamSummaryView: View {

    let viewData: [StreamSummaryViewData]

    var body: some View {
        Grid(verticalSpacing: .spacingMedium) {
            GridRow(alignment: .center) {
                Text("Metric")
                Text("Min")
                Text("Average")
                Text("Max")
            }
            .font(.headline)
            .frame(maxWidth: .infinity)

            ForEach(viewData, id: \.type) { data in
                Divider()
                GridRow(alignment: .center) {
                    Text(data.type.title)
                    Text(
                        data.min.measurement,
                        format: data.min.format
                    )
                    Text(
                        data.average.measurement,
                        format: data.average.format
                    )
                    Text(
                        data.max.measurement,
                        format: data.average.format
                    )
                }.font(.callout)
            }
        }
        .padding(.spacingSmall)
        .background {
            Color.gray.opacity(0.2)
        }
        .cornerRadius(.spacingSmall)
    }

}
