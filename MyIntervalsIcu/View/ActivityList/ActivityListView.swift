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
                    switch activity {
                    case .activity(let activity):
                        ActivityCellView(activity: activity)
                    case .section(let activities, let sectionDate):
                        Section {
                            ForEach(activities) { activity in
                                ActivityCellView(activity: activity)
                            }
                            
                        }
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

private struct ActivityCellView : View {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    let activity: ActivityListViewData.ActivityListSummary
    
    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack {
                ActivityCellInfoView(activity: activity)
                    .frame(maxWidth: .infinity)
                SummaryBarChartView(bars: activity.summaryChartBars)
                    .frame(maxWidth: .infinity)
            }
            
            VStack(alignment: .leading) {
                ActivityCellInfoView(activity: activity)
                    .frame(maxHeight: .infinity)
                SummaryBarChartView(bars: activity.summaryChartBars)
                    .frame(maxHeight: .infinity)
            }
        }
    }
    
}

private struct ActivityCellInfoView : View {
    let activity: ActivityListViewData.ActivityListSummary
    
    var body: some View {
        VStack(alignment: .leading, spacing: .spacingSmall) {
            let activityDateTime = Text(activity.date, format: .dateTime)
            Text("\(activity.title): \(activityDateTime)")
            
            let activityElapsedTime = Text(activity.elapsedTime, format: .measurement(width: .abbreviated))
            Text("Time: \(activityElapsedTime)")
            
            Text(
                activity.distance,
                format: .measurement(
                    width: .abbreviated,
                    usage: .asProvided,
                    numberFormatStyle: .number.precision(.fractionLength(1))
                )
            )
        }
    }
}

private struct SummaryBarChartView: View {
    
    let bars: [ActivityListViewData.SummaryBar]
    
    var body: some View {
        GeometryReader { proxy in
            HStack(
                alignment: .bottom,
                spacing: CGFloat.zero
            ) {
                ForEach(bars) { bar in
                    bar.zone.zoneColor
                        .frame(
                            width: proxy.size.width * bar.widthPercentage,
                            height: proxy.size.height * bar.heightPercentage,
                            alignment: .bottom
                        )
                }
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .background {
                Color.gray.opacity(0.5)
            }
        }
        .cornerRadius(.spacingXSmall)
    }
}
