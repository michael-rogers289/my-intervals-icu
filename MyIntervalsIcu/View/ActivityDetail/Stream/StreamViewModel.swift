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
    private var summaryCancellable: Task<Void, Never>?
    private var streamsObservationTask: Task<Void, Never>?
    private var streamTask: Task<Void, Never>?
    
    // MARK: Public Variables
    
    private(set) var viewData: [StreamViewData.TimeSeries] = []
    var selectableStreamTypes: [StreamLegendViewData] = [] {
        didSet {
            guard let selectedActivityId = selectedActivityId else { return }
            let filteringTypes = selectableStreamTypes
                .filter { $0.isSelected }
                .map { $0.streamType.asData }
            startStreamObservation(
                with: selectedActivityId,
                filteringBy: filteringTypes
            )
            updateSummary(
                with: selectedActivityId,
                filteringBy: filteringTypes
            )
        }
    }
    private(set) var streamSummaryData: [any StreamSummaryViewData] = []
    
    var subsectionStartIndex: Int?
    var subsectionEndIndex: Int?
    
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
            .replaceError(with: [])
            .removeDuplicates()
            .sink { [weak self] in
                self?.getStreams(forActivity: selectedActivityId, with: $0)
                self?.selectableStreamTypes = $0.compactMap {
                    guard let streamType = TimeSeriesStreamType(streamType: $0) else { return nil }
                    return StreamLegendViewData(streamType: streamType, isSelected: streamType.defaultPlottable)
                }
                .sorted { $0.streamType.rawValue < $1.streamType.rawValue }
            }
            .store(in: &cancellables)
    }
    
    private func updateSummary(with selectedActivityId: Activity.ActivityId, filteringBy types: [StreamType]) {
        summaryCancellable?.cancel()
        summaryCancellable = Task { [weak self] in
            do {
                guard let summaries = try await self?.streamRepository.observeSummaries(for: selectedActivityId, filteringBy: types) else {
                    return
                }
                for try await summary in summaries {
                    self?.streamSummaryData = summary
                        .compactMap { summary in
                            guard let timeSeriesType = TimeSeriesStreamType(streamType: summary.type),
                                let measurementType = timeSeriesType.measurementType else { return nil }
                            return AStreamSummaryViewData(
                                type: timeSeriesType,
                                min: Measurement(value: summary.min, unit: measurementType),
                                average: Measurement(value: summary.average, unit: measurementType),
                                max: Measurement(value: summary.max, unit: measurementType)
                            )
                        }
                }
            } catch {
                print("SUMMARIES ERROR \(error)")
            }
        }
    }
    
    private func startStreamObservation(with selectedActivityId: Activity.ActivityId, filteringBy types: [StreamType]) {
        streamsObservationTask?.cancel()
        streamsObservationTask = Task { [weak self] in
            do {
                guard let streamObservation = try await self?.streamRepository.observeStreams(for: selectedActivityId, filteringBy: types) else { return }
                
                for try await streamDictionary in streamObservation {
                    self?.viewData = streamDictionary.compactMap { (key, value) -> StreamViewData.TimeSeries? in
                        guard let timeSeriesType = TimeSeriesStreamType(streamType: key) else { return nil }
                        return StreamViewData.TimeSeries(
                            streamType: timeSeriesType,
                            plottableData: value.map {
                                StreamViewData.Point(
                                    x: Double($0.order),
                                    y: $0.value
                                )
                            },
                        )
                    }.sorted { $0.streamType.rawValue < $1.streamType.rawValue }
                }
            } catch {
                print("Streams error: \(error)")
            }
        }
    }
    
}
