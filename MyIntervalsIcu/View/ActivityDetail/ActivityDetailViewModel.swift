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

    enum Constant {
        static let defaultRange: Range<Double> = 0.0..<1.0
    }

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
    @Published private var selectedRange: Range<Double>?
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

    @ObservationTracked
    var currentSelectionRange: Range<Double>? {
        selectedRange
    }

    var selectionRanges: AnyPublisher<Range<Double>?, Error> {
        $selectedRange
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
        guard
            var firstSelectionRangeAsPercent = firstSelectionRangeAsPercent?.clamped(to: Constant.defaultRange),
            var secondSelectionRangeAsPercent = secondSelectionRangeAsPercent?.clamped(to: Constant.defaultRange) else {
            selectedRange = nil
            return
        }

        if firstSelectionRangeAsPercent ~= secondSelectionRangeAsPercent && firstSelectionRangeAsPercent != 1.0 {
            secondSelectionRangeAsPercent += 0.01
        } else if firstSelectionRangeAsPercent ~= secondSelectionRangeAsPercent && firstSelectionRangeAsPercent == 1.0 {
            firstSelectionRangeAsPercent -= 0.01
        }

        let actualBottom = min(firstSelectionRangeAsPercent, secondSelectionRangeAsPercent)
        let actualTop = max(firstSelectionRangeAsPercent, secondSelectionRangeAsPercent)

        selectedRange = (actualBottom..<actualTop)

        if actualBottom != firstSelectionRangeAsPercent {
            self.firstSelectionRangeAsPercent = actualBottom
        }

        if actualTop != secondSelectionRangeAsPercent {
            self.secondSelectionRangeAsPercent = actualTop
        }
    }

}
