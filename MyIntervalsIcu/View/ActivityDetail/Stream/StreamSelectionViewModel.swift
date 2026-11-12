//
//  StreamSelectionViewModel.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 11/3/26.
//

import Combine
import FactoryKit
import Foundation
import SwiftUI

@Observable
@MainActor
final class StreamSelectionViewModel: SelectionViewModel {

    enum Constant {
        static let defaultRange: Range<Double> = 0.0..<1.0
    }

    // MARK: Private Properties

    @ObservationIgnored
    @Injected(\.streamRepository)
    private var streamRepository

    @ObservationIgnored
    @Injected(\.detailActivityIdSelector)
    private var selectedActivityId

    @ObservationIgnored
    @Injected(\.viewLogger)
    private var viewLogger

    @ObservationIgnored
    @Published
    private var selectedRange: Range<Double>?
    @ObservationIgnored
    @Published
    private var _selectionRangeAsOrder: Range<Int>?
    @ObservationIgnored
    @Published
    private var secondsTimeSeries: [Stream] = []
    private var cancellables: Set<AnyCancellable> = []

    // MARK: Public Properties

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

    // Used for UI work to compute frame sizes or placement of elements
    var selectionRangeAsPercent: AnyPublisher<Range<Double>?, Error> {
        $selectedRange
            .removeDuplicates()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    // Used to get ranges of various streams for the activity in the data layer
    var selectionRangeAsOrder: AnyPublisher<Range<Int>?, Never> {
        $_selectionRangeAsOrder
            .eraseToAnyPublisher()
    }

    // MARK: Lifecycle

    init() {
        guard let selectedActivityId else { return }
        streamRepository.observeTimeStream(for: selectedActivityId)
            .combineLatest($selectedRange.setFailureType(to: Error.self))
            .sink { [weak self] error in
                self?.viewLogger.logError(message: "Error fetching last time second: \(error)")
            } onReceieveValue: { [weak self] stream, selectedRange in
                self?.secondsTimeSeries = stream

                guard let selectedRange,
                    let maxSecondOrder = stream.last?.order.toDouble() else {
                    self?._selectionRangeAsOrder = nil
                    return
                }

                let lowerBound = Int(selectedRange.lowerBound * maxSecondOrder)
                let upperBound = Int(selectedRange.upperBound * maxSecondOrder)
                self?._selectionRangeAsOrder = lowerBound..<upperBound
            }
            .store(in: &cancellables)
    }

    // MARK: Public Methods

    func resetSelectionRange() {
        secondSelectionRangeAsPercent = nil
        firstSelectionRangeAsPercent = nil
        _selectionRangeAsOrder = nil
        selectedRange = nil
    }

    // MARK: Private Methods

    private func validateRanges() {
        guard var firstSelectionRangeAsPercent = firstSelectionRangeAsPercent?
            .clamped(to: Constant.defaultRange),
              var secondSelectionRangeAsPercent = secondSelectionRangeAsPercent?
            .clamped(to: Constant.defaultRange) else {
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
