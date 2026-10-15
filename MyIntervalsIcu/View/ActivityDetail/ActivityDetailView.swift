//
//  ActivityDetailView.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 9/23/26.
//

import SwiftUI

struct ActivityDetailView : View {
    
    @State private var viewModel = ActivityDetailViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .spacingMedium) {
                if let summaryInfo = viewModel.summaryInfo {
                    ActivitySummaryInfoView(
                        viewData: summaryInfo
                    )
                    .padding(.spacingMedium)
                    StreamView()
                } else {
                    EmptyView()
                }
            }
        }
        .padding(.spacingLarge)
        .onAppear { viewModel.startObservation() }
    }
    
}
