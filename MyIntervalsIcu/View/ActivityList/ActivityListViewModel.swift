//
//  ActivityListViewModel.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 9/23/26.
//

import Combine
import Foundation
import SwiftUI

@MainActor
@Observable
final class ActivityListViewModel {
    
    // MARK: Private Variables
    private let activityRepository: ActivityRepository = BladeMyIntervalsIcuComponent().activityRepository()
    private var currentMonth: DateInterval
    private var refreshTask: Task<Void, Never>?
    private var summaryChartTask: Task<Void, Never>?
    private var cancellables: Set<AnyCancellable> = []
    
    //MARK: Public Variables
    private(set) var activities: [ActivityListViewData] = []
    
    // MARK: Init
    init() {
        do {
            currentMonth = try CalendarRepository.getCurrentMonth(from: Date())
            print("CURRENT MONTH: \(currentMonth)")
        } catch {
            fatalError("Unable to create date for current week")
        }
    }
    
    // MARK: Public Methods
    func startObservation() {
        refresh()
        cancellables.removeAll()
        activityRepository.getActivities(for: currentMonth)
            .replaceError(with: [])
            .sink { [weak self] activities in self?.getSummaryChartBars(for: activities) }
            .store(in: &cancellables)
    }
    
    //MARK: Private Methods
    private func refresh() {
        let currentMonth = currentMonth
        refreshTask = Task { [weak self] in
            defer {
                self?.refreshTask = nil
            }
            do {
                try await self?.activityRepository.fetchActivitiesForDateRange(range: currentMonth)
            } catch {
                print("Got error from network: \(error)")
            }
        }
    }
    
    private func getSummaryChartBars(for activities: [Activity]) {
        summaryChartTask = Task {
            var charts: [String: [SummaryChartBar]] = [:]
            do {
                charts = try await activityRepository.getGroupedSummaryChartBars(for: activities)
            } catch {
                print("Error while getting charts: \(error)")
            }
            
            self.activities = Dictionary(grouping: activities) { activity in
                CalendarRepository.startOfDay(on: activity.startDate)
            }
            .map { startDate, activities in
                ActivityListViewData(
                    activities: activities
                        .sorted { $0.startDate > $1.startDate }
                        .map { activity in
                            let bars = (charts[activity.id] ?? []).sorted { $0.xChartPosition < $1.xChartPosition }
                            let totalWidth: CGFloat = if let maxXPositionBar = bars.last {
                                CGFloat(maxXPositionBar.width + maxXPositionBar.xChartPosition)
                            } else {
                                1.0 // 1 to just avoid NAN with divide by zero
                            }
                            
                            return ActivityListViewData.ActivityListSummary(
                                id: activity.id,
                                summaryInfoViewData: ActivitySummaryInfoViewData(activity: activity),
                                summaryChartBars: bars.map {
                                    ActivityListViewData.SummaryBar(
                                        id: $0.id,
                                        widthPercentage: CGFloat($0.width) / totalWidth,
                                        heightPercentage: CGFloat($0.zone) / CGFloat($0.totalNumZones),
                                        zone: $0.zone
                                    )
                                }
                            )
                        },
                    activityDate: startDate
                )
            }
            .sorted { $0.activityDate > $1.activityDate }
        }
        
    }
}
    
