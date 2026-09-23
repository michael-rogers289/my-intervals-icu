//
//  ActivityListView.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 9/23/26.
//

import SwiftUI

struct ActivityListView : View {
    
    @State private var viewModel = ActivityListViewModel()
    @State private var navigationViewModel = ActivityNavigationViewModel()
    
    var body: some View {
        NavigationStack(path: $navigationViewModel.stack) {
            List(viewModel.activities) { activity in
                NavigationLink("ID: \(activity.id)", value: ActivityNavigationElement.detail(activityId: activity.id))
            }
            .navigationDestination(for: ActivityNavigationElement.self) { destination in
                switch destination {
                case .detail(let id):
                    ActivityDetailView()
                }
            }
            .navigationTitle("Activities")
        }
        .onAppear { viewModel.startObservation() }
        
    }
    
}
