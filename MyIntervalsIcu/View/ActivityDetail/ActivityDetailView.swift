//
//  ActivityDetailView.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 9/23/26.
//

import SwiftUI

struct ActivityDetailView : View {
    
    @State private var viewModel = ActivityDetailViewModel()
    @State private var isErrorPresented = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .spacingMedium) {
                if let summaryInfo = viewModel.summaryInfo {
                    ActivitySummaryInfoView(
                        viewData: summaryInfo
                    )
                    .onTapGesture {
                        withAnimation {
                            isErrorPresented = true
                        }
                        
                    }
                    .padding(.spacingMedium)
                    StreamView()
                } else {
                    EmptyView()
                }
            }
        }
        .padding(.spacingLarge)
        .onAppear { viewModel.startObservation() }
        .overlay(alignment: .bottom) {
            if isErrorPresented {
                ErrorView(isPresented: $isErrorPresented, viewData: ErrorViewData(errorText: "Something went wrong. Please try again", error: nil))
            }
        }
    }
    
}
