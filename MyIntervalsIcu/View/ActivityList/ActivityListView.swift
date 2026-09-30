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
                ForEach(viewModel.activities) { viewData in
                    Section {
                        Text(viewData.activityDate, style: .date)
                            .font(.title)
                            .padding(.bottom, .spacingSmall)
                        
                        ForEach(viewData.activities) { activity in
                            NavigationLink(value: ActivityNavigationElement.detail(activityId: activity.id)) {
                                ActivityCellView(activity: activity)
                            }
                        }
                    }
                }
            }
            .navigationDestination(for: ActivityNavigationElement.self) { destination in
                switch destination {
                case .detail(let id):
                    ActivityDetailView(activityId: id)
                }
            }
            .navigationTitle("Activities")
        }
        .onAppear { viewModel.startObservation() }
        
    }
    
}

private struct ActivityCellView : View {
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var barChartWidth: CGFloat?
    let activity: ActivityListViewData.ActivityListSummary
    
    var body: some View {
            switch horizontalSizeClass {
            case .regular:
                
                HStack {
                    ActivitySummaryInfoView(viewData: activity.summaryInfoViewData)
                        .frame(maxWidth: .infinity, maxHeight: .infinity,  alignment: .topLeading)
                    SummaryBarChartView(bars: activity.summaryChartBars)
                        .frame(maxWidth: barChartWidth ?? .infinity, maxHeight: .infinity, alignment: .topTrailing)
                }.onGeometryChange(for: (CGFloat?).self) { proxy in
                    if #available(iOS 27.1, *),
                       let reservedRegion = proxy.reservedRegions(kind: .division).first {
                        return (proxy.size.width / 2.0) - (reservedRegion.frame.width + reservedRegion.margins.trailing) - .spacingMedium
                    } else {
                        return nil
                    }
                    
                } action: { newReservedRegion in
                    barChartWidth = newReservedRegion
                }

            default:
                VStack(alignment: .leading) {
                    ActivitySummaryInfoView(viewData: activity.summaryInfoViewData)
                        .frame(maxHeight: .infinity)
                    SummaryBarChartView(bars: activity.summaryChartBars)
                        .frame(minHeight: 100.0, maxHeight: .infinity)
                }
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
            .frame(
                maxHeight: .infinity,
                alignment: .bottom,
            )
            .background {
                Color.gray.opacity(0.5)
            }
        }
        .cornerRadius(.spacingXSmall)
    }
}
