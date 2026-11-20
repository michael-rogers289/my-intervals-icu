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

    @State private var showFullRow = false

    init(
        firstViewData: StreamSummaryViewData,
        secondViewData: StreamSummaryViewData?,
        selectedTimeRangeViewData: TimeRangeViewData?,
    ) {
        self.firstViewData = firstViewData
        self.secondViewData = secondViewData
        self.selectedTimeRangeViewData = selectedTimeRangeViewData
        self.showFullRow = false
    }

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

            if let secondViewData, let selectedTimeRangeViewData {
                Divider()
                selectedTimeRangeRow(
                    viewData: secondViewData,
                    selectedTimeRangeViewData: selectedTimeRangeViewData
                )

                if showFullRow {
                    fullSummaryRow
                }
            } else {
                Divider()
                fullSummaryRow
            }
        }
        .tint(.primary)
        .textScale(Text.Scale.secondary)
        .padding(.spacingXSmall)
        .background {
            Color.gray.opacity(0.2)
        }
        .cornerRadius(.spacingSmall)
    }

    private func selectedTimeRangeRow(
        viewData: StreamSummaryViewData,
        selectedTimeRangeViewData: TimeRangeViewData,
    ) -> some View {
        summary(for: viewData) {
            Button {
                showFullRow.toggle()
            } label: {
                HStack(spacing: .spacingMedium) {
                    Image(systemName: "chevron.right")
                        .rotationEffect(showFullRow ? .degrees(90.0) : .zero)
                        .animation(.bouncy, value: showFullRow)

                    ViewThatFits(in: .horizontal) {
                        let start = Text(selectedTimeRangeViewData.start, format: .timeDuration)
                        let end = Text(selectedTimeRangeViewData.end, format: .timeDuration)
                        Label("\(start) - \(end)", systemImage: "line.3.horizontal.decrease.circle.fill")

                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle.fill")
                        Text("Filter")
                    }
                }
            }

        }
    }

    private var fullSummaryRow: some View {
        summary(for: firstViewData) {
            ViewThatFits(in: .horizontal) {
                Label(
                    "Summary",
                    systemImage: "point.bottomleft.forward.to.point.topright.scurvepath.fill"
                )
                Text("Summary")
            }
        }
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
                format: viewData.max.format
            )
        }
        .font(.callout)
        .padding(.vertical, .spacingSmall)
    }

}
