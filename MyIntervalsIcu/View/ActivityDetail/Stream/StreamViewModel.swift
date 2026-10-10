//
//  StreamViewModel.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/4/26.
//

import Combine
import FactoryKit
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
    private var streamTask: Task<Void, Never>?
    private var selectableTypesTask: Task<Void, Never>?
    private var allTimeSeries: [StreamViewData.TimeSeries] = []
    private var timeSeriesXMax: Double = .zero
    
    // MARK: Public Variables
    
    private(set) var viewData = StreamViewData(
        timeSeries: [],
        areaTimeSeries: nil,
        xMax: .zero,
        timeSeriesMaxY: .zero
    )
    var selectableStreamTypes: [StreamLegendViewData] = []
    private(set) var streamSummaryData: [any StreamSummaryViewData] = []
    
    var subsectionStartIndex: Int?
    var subsectionEndIndex: Int?
    
    // MARK: Life Cycle
    
    init() {
        guard let selectedActivityId = selectedActivityId else { return }
        streamRepository.getAllowedStreams(for: selectedActivityId)
            .replaceError(with: [])
            .removeDuplicates()
            .sink { [weak self] in self?.getStreams(forActivity: selectedActivityId, with: $0) }
            .store(in: &cancellables)
    }
    
    // MARK: Private Methods
    
    private func updateStreamViewData(with selectableStreamTypes: [StreamLegendViewData]) {
        let selectedStreamTypes = Set<TimeSeriesStreamType>(
            selectableStreamTypes.compactMap {
                guard $0.isSelected else { return nil }
                return $0.streamType
            }
        )
        let selectedSeries = allTimeSeries
            .filter { selectedStreamTypes.contains($0.streamType) }
        guard let maxY = selectedSeries.max(by: { $0.maxY < $1.maxY })?.maxY else {
            return
        }
        
        let scaledSelectedSeries = selectedSeries.map {
            let scaleFactor = maxY / $0.maxY
            return $0.copy(updatedPoints: $0.plottableData.map { point in
                StreamViewData.Point(
                    yValueTitle: point.yValueTitle,
                    x: point.x,
                    y: point.y * scaleFactor
                )
            })
        }
        
        viewData = StreamViewData(
            timeSeries: scaledSelectedSeries.filter { $0.streamType != .altitude },
            areaTimeSeries: scaledSelectedSeries.first { $0.streamType == .altitude },
            xMax: timeSeriesXMax,
            timeSeriesMaxY: maxY,
        )
        
        streamSummaryData = selectedSeries.compactMap { timeSeries in
            guard let measurementType = timeSeries.streamType.measurementType else { return nil }
            return AStreamSummaryViewData(
                type: timeSeries.streamType,
                min: Measurement(value: timeSeries.minY, unit: measurementType).converted(to: measurementType),
                average: Measurement(value: timeSeries.averageY, unit: measurementType).converted(to: measurementType),
                max: Measurement(value: timeSeries.maxY, unit: measurementType).converted(to: measurementType),
            )
        }
    }
    
    private func getStreams(forActivity activityId: Activity.ActivityId, with types: [StreamType]) {
        streamTask?.cancel()
        streamTask = Task {
            let streams = await streamRepository.getStreams(
                types,
                for: activityId
            )
            guard !Task.isCancelled,
                  let secondsSeries = streams.first(where: { $0.type == .time }) else { return }
            
            allTimeSeries = streams
                .compactMap { stream in
                    guard let timeSeriesStreamType = TimeSeriesStreamType(streamType: stream.type) else { return nil }
                    
                    let timeSeriesSum = if timeSeriesStreamType.removeZerosWhenComputingAverage {
                        stream.timeSeries.filter { $0 != .zero }
                    } else {
                        stream.timeSeries
                    }
                    
                    return StreamViewData.TimeSeries(
                        streamType: timeSeriesStreamType,
                        plottableData: stream.timeSeries.enumerated().map { index, value in
                            StreamViewData.Point(
                                yValueTitle: timeSeriesStreamType.title,
                                x: secondsSeries.timeSeries[index],
                                y: value
                            )
                        },
                        minY: stream.timeSeries.min() ?? .zero,
                        maxY: stream.timeSeries.max() ?? .zero,
                        averageY: timeSeriesSum.reduce(0.0, { $0 + $1 }) / Double(timeSeriesSum.count)
                    )
                }
            
            timeSeriesXMax = secondsSeries.timeSeries.last ?? .zero
            
            selectableStreamTypes = allTimeSeries.map {
                StreamLegendViewData(streamType: $0.streamType, isSelected: $0.streamType.defaultPlottable)
            }
            startSelectionObservation()
        }
    }
    
    private func startSelectionObservation() {
        selectableTypesTask?.cancel()
        selectableTypesTask = Task { [weak self] in
            let individualObservation = Observations { self?.selectableStreamTypes }
            for await observation in individualObservation {
                guard !Task.isCancelled,
                      let observation else {
                    self?.selectableTypesTask?.cancel()
                    self?.selectableTypesTask = nil
                    return
                }
                self?.updateStreamViewData(with: observation)
            }
        }
    }
    
}
