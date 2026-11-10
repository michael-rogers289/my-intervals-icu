//
//  ActivityDetailViewModel.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 9/30/26.
//

import Combine
import FactoryKit
import Foundation
import SwiftUI

@Observable
@MainActor
final class ActivityDetailViewModel {

    // MARK: Private Properties

    @ObservationIgnored
    @Injected(\.activityRepository)
    private var activityRepository

    @ObservationIgnored
    @Injected(\.detailActivityIdSelector)
    private var selectedActivityId

    @ObservationIgnored
    @Injected(\.viewLogger)
    private var viewLogger

    @ObservationIgnored
    @Injected(\.selectionViewModel)
    private var selectionViewModel

    @ObservationIgnored
    @Published
    private var currentActivity: Activity?

    private let activityMapper = ActivityMapper()
    private var cancellables: Set<AnyCancellable> = []

    // MARK: Public Properties

    private(set) var summaryInfo: ActivitySummaryInfoViewData?
    private(set) var timeRangeViewData: TimeRangeViewData?

    // MARK: Public Methods

    func startObservation() {
        guard let selectedActivityId else { return }
        activityRepository
            .getActivity(byId: selectedActivityId)
            .sink { [weak self] in
                self?.viewLogger.logError(message: "Error observing activity: \($0)")
            } onReceieveValue: { [weak self] activity in
                guard let activity else {
                    self?.summaryInfo = nil
                    return
                }
                self?.summaryInfo = self?.activityMapper.map(activity: activity)
                self?.currentActivity = activity
            }
            .store(in: &cancellables)

        selectionViewModel.selectionRangeAsOrder
            .combineLatest($currentActivity)
            .sink { [weak self] selectedRange, activity in
                guard let activity,
                      let selectedRange else { return }

                self?.timeRangeViewData = TimeRangeViewData(
                    activityStartTime: activity.startDate,
                    startSelectedSecond: selectedRange.lowerBound.toDouble(),
                    endSelectedSecond: selectedRange.upperBound.toDouble(),
                )
            }
            .store(in: &cancellables)
    }

}
