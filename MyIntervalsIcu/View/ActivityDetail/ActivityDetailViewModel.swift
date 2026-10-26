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
final class ActivityDetailViewModel: SelectionViewModel {

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

    private let rangePublisher = CurrentValueSubject<Range<Double>?, Never>(nil)
    private let activityMapper = ActivityMapper()
    private var cancellables: Set<AnyCancellable> = []

    // MARK: Public Properties

    private(set) var summaryInfo: ActivitySummaryInfoViewData?

    var secondSelectionRangeAsPercent: Double? {
        didSet {
            validateRanges()
        }
    }

    var firstSelectionRangeAsPercent: Double? {
        didSet {
            validateRanges()
        }
    }

    var selections: AnyPublisher<Range<Double>?, Error> {
        rangePublisher
            .removeDuplicates()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

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
            }
            .store(in: &cancellables)
    }

    func resetSelectionRange() {
        secondSelectionRangeAsPercent = nil
        firstSelectionRangeAsPercent = nil
    }

    // MARK: Private Methods

    private func validateRanges() {
        guard let firstSelectionRangeAsPercent,
              let secondSelectionRangeAsPercent else {
            rangePublisher.send(nil)
            return
        }

        let actualBottom = max(min(firstSelectionRangeAsPercent, secondSelectionRangeAsPercent), 0.0)
        let actualTop = min(max(firstSelectionRangeAsPercent, secondSelectionRangeAsPercent), 1.0)

        rangePublisher.value = (actualBottom..<actualTop)

        if actualBottom != firstSelectionRangeAsPercent {
            self.firstSelectionRangeAsPercent = actualBottom
        }

        if actualTop != secondSelectionRangeAsPercent {
            self.secondSelectionRangeAsPercent = actualTop
        }
    }

}
