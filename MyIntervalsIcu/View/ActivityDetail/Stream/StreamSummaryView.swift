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
                        "Activity",
                        systemImage: "point.bottomleft.forward.to.point.topright.scurvepath.fill"
                    )
                    Text("Activity")
                }
            }

            if let secondViewData {
                Divider()

                summary(for: secondViewData) {
                    ViewThatFits(in: .horizontal) {
                        Label(
                            "Selected",
                            systemImage: "line.3.horizontal.decrease.circle.fill"
                        )
                        Text("Selected")
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
        }.font(.callout)
    }

}
