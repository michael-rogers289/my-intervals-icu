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
                NavigationLink(value: ActivityNavigationElement.detail(activityId: activity.id)) {
                    VStack(alignment: .leading, spacing: .spacingSmall) {
                        let activityDateTime = Text(activity.startDate, format: .dateTime)
                        Text("\(activity.type ?? "Activity"): \(activityDateTime)")
                        
                        Text("Time: \(activity.elapsedTime ?? 0)")
                        
                        Text(
                            Measurement(value: activity.distince, unit: UnitLength.meters).converted(to: UnitLength.kilometers),
                            format: .measurement(
                                width: .abbreviated,
                                usage: .asProvided,
                                numberFormatStyle: .number.precision(.fractionLength(1))
                            )
                        )
                    }
                }
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
