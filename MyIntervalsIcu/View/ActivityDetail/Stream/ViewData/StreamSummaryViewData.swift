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
}
