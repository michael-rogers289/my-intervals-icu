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

    var upperSelectionRangeAsPercent: Double? {
        didSet {
            guard let lowerSelectionRangeAsPercent,
                  let upperSelectionRangeAsPercent else {
                rangePublisher.send(nil)
                return
            }

            let validatedValue = max(
                min(upperSelectionRangeAsPercent, 1.0),
                lowerSelectionRangeAsPercent
            )
            rangePublisher.value = (lowerSelectionRangeAsPercent..<validatedValue)

            guard validatedValue != upperSelectionRangeAsPercent else { return }
            self.upperSelectionRangeAsPercent = validatedValue
        }
    }

    var lowerSelectionRangeAsPercent: Double? {
        didSet {
            guard let lowerSelectionRangeAsPercent,
                  let upperSelectionRangeAsPercent else {
                rangePublisher.send(nil)
                return
            }

            let validatedValue = max(
                min(lowerSelectionRangeAsPercent, upperSelectionRangeAsPercent),
                0.0
            )
            rangePublisher.value = (validatedValue..<(upperSelectionRangeAsPercent))

            guard validatedValue != lowerSelectionRangeAsPercent else { return }
            self.lowerSelectionRangeAsPercent = validatedValue
        }
    }

    var selections: AnyPublisher<Range<Double>?, Error> {
        rangePublisher
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
        upperSelectionRangeAsPercent = nil
        lowerSelectionRangeAsPercent = nil
    }

}
