//
//  ActivityDetailView.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 9/23/26.
//

import FactoryKit
import SwiftUI

struct ActivityDetailView: View {

    @State private var viewModel = Container.shared.activityDetailViewModel.resolve()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .spacingMedium) {
                if let summaryInfo = viewModel.summaryInfo {
                    ActivitySummaryInfoView(
                        viewData: summaryInfo
                    )
                    StreamMapView()
                    StreamView()
                } else {
                    EmptyView()
                }
            }
        }
        .padding(.spacingMedium)
        .onAppear { viewModel.startObservation() }
    }

}
