//
//  StreamSummaryViewData.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/9/26.
//

import Foundation

struct StreamSummaryViewData {
    let type: TimeSeriesStreamType
    let min: TimeSeriesStreamTypeMeasurement
    let average: TimeSeriesStreamTypeMeasurement
    let max: TimeSeriesStreamTypeMeasurement

    init?(summary: StreamSummary, timeSeriesType: TimeSeriesStreamType) {

        let average = if timeSeriesType.removesZerosComputingAverage {
            timeSeriesType.measurementType(for: summary.averageExcludingZeros)
        } else {
            timeSeriesType.measurementType(for: summary.averageIncludingZeros)
        }
        let min = timeSeriesType.measurementType(for: summary.min)
        let max = timeSeriesType.measurementType(for: summary.max)
        guard let average, let min, let max else { return nil }
        self.type = timeSeriesType
        self.average = average
        self.min = min
        self.max = max
    }
}
