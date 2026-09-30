//
//  ActivityMapper.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 9/30/26.
//

import Foundation

struct ActivityMapper {
    
    private let calendarRepository: CalendarRepository
    
    func map(
        activity: Activity,
    ) -> ActivitySummaryInfoViewData {
        ActivitySummaryInfoViewData(
            title: activity.type ?? "Activity",
            startTime: CalendarRepository.getTime(from: activity.startDate),
            elapsedTime: CalendarRepository.formatInterval(from: activity.startDate, to: activity.endDate ?? activity.startDate) ?? "",
            distanceInKilometers: Measurement(value: activity.distince, unit: .meters).converted(to: UnitLength.kilometers),
        )
    }
    
}
