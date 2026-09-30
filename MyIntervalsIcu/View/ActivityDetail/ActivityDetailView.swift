//
//  ActivityDetailView.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 9/23/26.
//

import SwiftUI

struct ActivityDetailView : View {
    
    let activityId: String
    @State private var viewModel: ActivityDetailViewModel
    
    init(activityId: String) {
        self.activityId = activityId
        self.viewModel = ActivityDetailViewModel(id: activityId)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if let summaryInfo = viewModel.summaryInfo {
                ActivitySummaryInfoView(
                    viewData: summaryInfo
                )
            } else {
                EmptyView()
            }
        }
        .onAppear { viewModel.startObservation() }
    }
    
}
