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

    private var cancellables: Set<AnyCancellable> = []
    private var streamsObservationTask: Task<Void, Never>?
    private var streamTask: Task<Void, Never>?
    private var subsectionStreamTask: Task<Void, Never>?

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
    var selectableStreamTypes: [StreamLegendViewData] = [] {
        didSet {
            guard let selectedActivityId = selectedActivityId else { return }
            startStreamObservation(
                with: selectedActivityId,
                filteringBy: selectedStreamTypes
            )
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

    private func getStreams(forActivity activityId: Activity.ActivityId, with types: [StreamType]) {
        streamTask?.cancel()
        streamTask = Task {
            do {
                try await streamRepository.getStreams(
                    types,
                    for: activityId
                )
            } catch {
                print("Error getting streams: \(error)")
            }

        }
    }

    private func startAllowedStreamsObservation(with selectedActivityId: Activity.ActivityId) {
        streamRepository.observeAllowedStreams(for: selectedActivityId)
            .replaceError(with: []) // TODO: REMOVE ME
            .removeDuplicates()
            .sink { [weak self] in
                guard !$0.isEmpty else {
                    self?.selectableStreamTypes = []
                    return
                }
                self?.getStreams(forActivity: selectedActivityId, with: $0)
                self?.selectableStreamTypes = $0.compactMap {
                    guard let streamType = TimeSeriesStreamType(streamType: $0) else { return nil }
                    return StreamLegendViewData(streamType: streamType, isSelected: streamType.defaultPlottable)
                }
                .sorted { $0.streamType.rawValue < $1.streamType.rawValue }
            }
            .store(in: &cancellables)
    }

    private func getStreamsForSubsectionIndexIfNeeded(filteredBy streams: [StreamType]) {
        guard streams.isEmpty == false, // TODO: Reset
              let selectedActivityId,
              let selectedTimeRange else {
            return
        }
        subsectionStreamTask?.cancel()
        subsectionStreamTask = Task { [weak self] in
            do {
                try await Task.sleep(for: .milliseconds(400))
                guard !Task.isCancelled,
                      let currentViewData = self?.viewData else { return }

                let subsectionStreamSummary = try await self?.streamRepository.getSummaries(
                    for: selectedActivityId,
                    filteringBy: streams,
                    overTimeRange: selectedTimeRange,
                )

                self?.viewData = currentViewData.map { timeSeries -> StreamViewData.TimeSeries in
                    return StreamViewData.TimeSeries(
                        streamType: timeSeries.streamType,
                        plottableData: timeSeries.plottableData,
                        summary: timeSeries.summary,
                        filteredSummary: subsectionStreamSummary?
                            .first(where: { TimeSeriesStreamType(streamType: $0.type) == timeSeries.streamType })
                            .map { StreamSummaryViewData(summary: $0, timeSeriesType: timeSeries.streamType) }
                    )
                }
            } catch {
                guard !(error is CancellationError) else {
                    return
                }
                print("Error getting filtered summaries: \(error)")
            }
        }
    }

    private func startStreamObservation(with selectedActivityId: Activity.ActivityId, filteringBy types: [StreamType]) {
        guard !types.isEmpty else {
            viewData = []
            return
        }

        streamsObservationTask?.cancel()
        streamsObservationTask = Task { [weak self] in
            do {
                async let streams = try await self?.streamRepository.getStreams(
                    for: selectedActivityId,
                    filteringBy: types
                )
                async let summary = try await self?.streamRepository.getSummaries(
                    for: selectedActivityId,
                    filteringBy: types,
                )

                let filteredSummary: [StreamSummary]? = if let selectedTimeRange = self?.selectedTimeRange {
                    try await self?.streamRepository.getSummaries(
                        for: selectedActivityId,
                        filteringBy: types,
                        overTimeRange: selectedTimeRange,
                    )
                } else {
                    nil
                }

                guard let streams = try await streams,
                      let summary = try await summary else {
                    return
                }

                let mapped = streams.compactMap { (key, value) -> StreamViewData.TimeSeries? in
                    guard let timeSeriesType = TimeSeriesStreamType(streamType: key) else { return nil }
                    return StreamViewData.TimeSeries(
                        streamType: timeSeriesType,
                        plottableData: value.map {
                            StreamViewData.Point(
                                x: Double($0.order),
                                y: $0.value
                            )
                        },
                        summary: summary
                            .first(where: { $0.type == key })
                            .map { StreamSummaryViewData(summary: $0, timeSeriesType: timeSeriesType) },
                        filteredSummary: filteredSummary?.first(where: { $0.type == key })
                            .map { StreamSummaryViewData(summary: $0, timeSeriesType: timeSeriesType) }
                    )
                }.sorted { $0.streamType.rawValue < $1.streamType.rawValue }
                self?.viewData = mapped
            } catch {
                print("Streams error: \(error)")
            }
        }
    }

}

extension Optional {

    func map<R>(_ body: (Wrapped) throws -> R?) rethrows -> R? {
        if let wrapped = self {
            try body(wrapped)
        } else {
            nil
        }
    }

}
