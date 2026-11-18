//
//  ActivityDetailView.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 9/23/26.
//

import FactoryKit
import SwiftUI

struct ActivityDetailView: View {

    @State private var viewModel = ActivityDetailViewModel()
    @State private var scrollPosition = ScrollPosition(idType: TimeSeriesStreamType.self)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .spacingMedium) {
                if let overview = viewModel.overviewViewData {
                    ActivityDetailHeaderView(
                        viewData: overview
                    )
                    StreamMapView(detailViewModel: viewModel)
                    StreamView(selectedTimeRangeViewData: viewModel.timeRangeViewData)
                } else {
                    ProgressView {
                        Text("Loading...")
                    }
                }
            }
        }
        .environment(\.activityDetailScrollPosition, $scrollPosition)
        .scrollPosition($scrollPosition)
        .padding(.spacingMedium)
        .onAppear { viewModel.startObservation() }
    }

}

extension EnvironmentValues {
    @Entry var activityDetailScrollPosition: Binding<ScrollPosition> = .constant(
        ScrollPosition(idType: TimeSeriesStreamType.self)
    )
}
