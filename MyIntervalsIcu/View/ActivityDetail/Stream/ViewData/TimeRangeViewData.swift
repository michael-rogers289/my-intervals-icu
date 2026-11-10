//
//  TimeRangeViewData.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 11/2/26.
//

import Foundation

struct TimeRangeViewData {
    let start: Range<Date>
    let end: Range<Date>

    init(
        activityStartTime: Date,
        startSelectedSecond: Double,
        endSelectedSecond: Double
    ) {
        start = activityStartTime..<activityStartTime.addingTimeInterval(startSelectedSecond)
        end = activityStartTime..<activityStartTime.addingTimeInterval(endSelectedSecond)
    }
}
