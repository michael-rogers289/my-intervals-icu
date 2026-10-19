//
//  StreamSummaryView.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/8/26.
//

import SwiftUI

struct StreamSummaryView: View {

    let firstViewData: StreamSummaryViewData
    let secondViewData: StreamSummaryViewData?

    var body: some View {
        Grid(verticalSpacing: .spacingMedium) {
            GridRow(alignment: .center) {
                Color.clear
                Text("Min")
                Text("Average")
                Text("Max")
            }
            .font(.headline)
            .frame(maxWidth: .infinity)

            Divider()
            summary(for: firstViewData)
            if let secondViewData {
                Divider()
                summary(for: secondViewData)
            }

        }
        .padding(.spacingSmall)
        .background {
            Color.gray.opacity(0.2)
        }
        .cornerRadius(.spacingSmall)
    }

    private func summary(for viewData: StreamSummaryViewData) -> some View {
        GridRow(alignment: .center) {
            Text(viewData.type.title)
            Text(
                viewData.min.measurement,
                format: viewData.min.format
            )
            Text(
                viewData.average.measurement,
                format: viewData.average.format
            )
            Text(
                viewData.max.measurement,
                format: viewData.average.format
            )
        }.font(.callout)
    }

}
