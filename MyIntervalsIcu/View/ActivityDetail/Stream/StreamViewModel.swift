//
//  StreamViewModel.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/4/26.
//

import Combine
import FactoryKit
import GRDB
import Observation
import SwiftUI

@MainActor
@Observable
final class StreamViewModel {

    // MARK: Private Variables

    @ObservationIgnored
    @Injected(\.streamRepository)
    private var streamRepository

    @ObservationIgnored
    @Injected(\.detailActivityIdSelector)
    private var selectedActivityId

    @ObservationIgnored
    @Injected(\.viewLogger)
    private var viewLogger

    private var streamLegendCancellable: AnyCancellable?
    private var streamCancellable: AnyCancellable?
    private var selectedTimeRangeSummaryCancellable: AnyCancellable?
    private var summaryStreamCancellable: AnyCancellable?
    private var streamRefreshTask: Task<Void, Never>?
    private var selectedTimeRangeDebounceTask: Task<Void, Never>?

    private var selectedTimeRange: Range<Int>? {
        guard let subsectionStartIndex, let subsectionEndIndex else { return nil }
        return min(subsectionStartIndex, subsectionEndIndex)..<max(subsectionEndIndex, subsectionStartIndex)
    }
    private var selectedStreamTypes: [StreamType] {
        selectableStreamTypes
            .filter { $0.isSelected }
            .map { $0.streamType.asData }
    }

    // MARK: Public Variables

    private(set) var viewData: [StreamViewData.TimeSeries] = []
    private(set) var summaryViewData: [TimeSeriesStreamType: StreamSummaryViewData] = [:]
    private(set) var filteredSummaryViewData: [TimeSeriesStreamType: StreamSummaryViewData] = [:]
    var selectableStreamTypes: [StreamLegendViewData] = [] {
        didSet {
            guard let selectedActivityId = selectedActivityId else { return }
            let selectedStreams = selectedStreamTypes
            startStreamObservation(
                with: selectedActivityId,
                filteringBy: selectedStreams
            )
            startSummaryObservation(with: selectedActivityId, filteringBy: selectedStreams)
            getStreamsForSubsectionIndexIfNeeded(filteredBy: selectedStreams)
        }
    }

    var subsectionStartIndex: Int?
    var subsectionEndIndex: Int? {
        didSet {
            getStreamsForSubsectionIndexIfNeeded(filteredBy: selectedStreamTypes)
        }
    }

    // MARK: Life Cycle

    init() {
        guard let selectedActivityId = selectedActivityId else { return }
        startAllowedStreamsObservation(with: selectedActivityId)
    }

    // MARK: Private Methods

    private func resetObservers() {
        selectableStreamTypes = []
        summaryStreamCancellable?.cancel()
        summaryStreamCancellable = nil
        streamCancellable?.cancel()
        streamCancellable = nil
        filteredSummaryViewData = [:]
        selectedTimeRangeSummaryCancellable?.cancel()
        selectedTimeRangeSummaryCancellable = nil
    }

    private func getStreams(forActivity activityId: Activity.ActivityId, with types: [StreamType]) {
        streamRefreshTask?.cancel()
        streamRefreshTask = Task { [weak self] in
            do {
                try await self?.streamRepository.getStreams(
                    types,
                    for: activityId
                )
                self?.viewLogger.logDebug(message: "successfully got streams")
            } catch {
                self?.viewLogger.logError(message: "Error getting streams: \(error)")
            }
        }
    }

    private func startAllowedStreamsObservation(with selectedActivityId: Activity.ActivityId) {
        streamLegendCancellable = streamRepository.observeAllowedStreams(for: selectedActivityId)
            .removeDuplicates()
            .sink { [weak self] in
                self?.viewLogger.logError(message: "Error observing stream types \($0)")
            } onReceieveValue: { [weak self] in
                guard !$0.isEmpty else {
                    self?.resetObservers()
                    return
                }

                self?.getStreams(forActivity: selectedActivityId, with: $0)

                self?.selectableStreamTypes = $0.compactMap {
                    guard let streamType = TimeSeriesStreamType(streamType: $0) else { return nil }
                    return StreamLegendViewData(streamType: streamType, isSelected: streamType.defaultPlottable)
                }
                .sorted { $0.streamType.rawValue < $1.streamType.rawValue }
            }
    }

    private func getStreamsForSubsectionIndexIfNeeded(filteredBy types: [StreamType]) {
        guard types.isEmpty == false,
              let selectedActivityId,
              let selectedTimeRange else {
            filteredSummaryViewData = [:]
            return
        }

        selectedTimeRangeSummaryCancellable?.cancel()
        selectedTimeRangeDebounceTask?.cancel()

        selectedTimeRangeDebounceTask = Task { [weak self] in
            do {
                try await Task.sleep(for: .milliseconds(400))
                guard !Task.isCancelled else { return }

                self?.selectedTimeRangeSummaryCancellable = self?.streamRepository.getSummaries(
                    for: selectedActivityId,
                    filteringBy: types,
                    overTimeRange: selectedTimeRange,
                )
                .removeDuplicates()
                .sink { [weak self] in
                    self?.viewLogger.logError(message: "Error getting filtered summaries: \($0)")
                } onReceieveValue: { [weak self] in
                    self?.viewLogger.logDebug(message: "receiving filtered summaries")
                    self?.filteredSummaryViewData = $0.asSummaryDictionary
                }
            } catch {
                guard !(error is CancellationError) else {
                    return
                }
                self?.viewLogger.logError(message: "Error getting filtered summaries: \(error)")
            }
        }
    }

    private func startSummaryObservation(
        with selectedActivityId: Activity.ActivityId,
        filteringBy types: [StreamType]
    ) {
        guard types.isEmpty == false else {
            summaryViewData = [:]
            return
        }
        summaryStreamCancellable?.cancel()
        summaryStreamCancellable = streamRepository.getSummaries(for: selectedActivityId, filteringBy: types)
            .removeDuplicates()
            .sink { [weak self] in
                self?.viewLogger.logError(message: "Error getting summaries: \($0)")
            } onReceieveValue: { [weak self] in
                self?.summaryViewData = $0.asSummaryDictionary
                self?.viewLogger.logDebug(message: "receiving summaries")
            }
    }

    private func startStreamObservation(with selectedActivityId: Activity.ActivityId, filteringBy types: [StreamType]) {
        guard !types.isEmpty else {
            viewData = []
            return
        }
        streamCancellable?.cancel()
        streamCancellable = streamRepository.getStreams(
            for: selectedActivityId,
            filteringBy: types
        )
        .removeDuplicates()
        .sink { [weak self] in
            self?.viewLogger.logError(message: "Streams error: \($0)")
        } onReceieveValue: { [weak self] in
            self?.viewData = $0.compactMap { (key, value) -> StreamViewData.TimeSeries? in
                guard let timeSeriesType = TimeSeriesStreamType(streamType: key) else { return nil }
                return StreamViewData.TimeSeries(
                    streamType: timeSeriesType,
                    plottableData: value.map { StreamViewData.Point(x: Double($0.order), y: $0.value) }
                )
            }.sorted { $0.streamType.rawValue < $1.streamType.rawValue }
            self?.viewLogger.logDebug(message: "received streams")
        }
    }

}

fileprivate extension Array<StreamSummary> {

    var asSummaryDictionary: [TimeSeriesStreamType: StreamSummaryViewData] {
        self.reduce(into: [:]) { summaryDictionary, summary in
            guard let type = TimeSeriesStreamType(streamType: summary.type) else { return }
            summaryDictionary[type] = StreamSummaryViewData(summary: summary, timeSeriesType: type)
        }
    }

}
