//
//  ActivityDetailView.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 9/23/26.
//

import SwiftUI

struct ActivityDetailView : View {
    
    @State private var viewModel = ActivityDetailViewModel()
    @State private var streamViewModel = StreamViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .spacingMedium) {
                if let summaryInfo = viewModel.summaryInfo {
                    ActivitySummaryInfoView(
                        viewData: summaryInfo
                    )
                    StreamLegendView(
                        viewData: streamViewModel.selectableStreamTypes,
                        onSelectionChanged: streamViewModel.onSelectedStreamTypeChanged
                    )
                    StreamView(viewData: streamViewModel.viewData)
                        .aspectRatio(1.0 / 0.25, contentMode: .fill)
                        .padding(.spacingMedium)
                } else {
                    EmptyView()
                }
                
            }
        }
        .padding(.spacingLarge)
        .onAppear { viewModel.startObservation() }
    }
    
}
