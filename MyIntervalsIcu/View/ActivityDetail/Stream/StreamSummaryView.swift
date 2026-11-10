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
    let selectedTimeRangeViewData: TimeRangeViewData?

    var body: some View {
        return Grid(verticalSpacing: .spacingSmall) {
            GridRow(alignment: .center) {
                Color.clear
                Text("Min")
                Text("Average")
                Text("Max")
            }
            .font(.headline)
            .frame(maxWidth: .infinity)

            Divider()

            summary(for: firstViewData) {
                ViewThatFits(in: .horizontal) {
                    Label(
                        "Summary",
                        systemImage: "point.bottomleft.forward.to.point.topright.scurvepath.fill"
                    )
                    Text("Summary")
                }
            }

            if let secondViewData {
                Divider()

                summary(for: secondViewData) {
                    ViewThatFits(in: .horizontal) {
                        if let selectedTimeRangeViewData {
                            let start = Text(selectedTimeRangeViewData.start, format: .timeDuration)
                            let end = Text(selectedTimeRangeViewData.end, format: .timeDuration)
                            Label("Filter: \(start) - \(end)", systemImage: "line.3.horizontal.decrease.circle.fill")
                        }

                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle.fill")
                        Text("Filter")
                    }
                }
            }
        }
        .textScale(Text.Scale.secondary)
        .padding(.spacingXSmall)
        .background {
            Color.gray.opacity(0.2)
        }
        .cornerRadius(.spacingSmall)
    }

    private func summary(
        for viewData: StreamSummaryViewData,
        @ViewBuilder label: () -> some View
    ) -> some View {
        GridRow(alignment: .center) {
            label()
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
        }
        .font(.callout)
        .padding(.vertical, .spacingSmall)
    }

}
