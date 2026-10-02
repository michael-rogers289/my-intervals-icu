//
//  ActivityMapper.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 9/30/26.
//

import FactoryKit
import Foundation

struct ActivityMapper {
    
    @Injected(\.calendarRepository)
    private var calendarRepository
    
    func map(
        activity: Activity,
    ) -> ActivitySummaryInfoViewData {
        ActivitySummaryInfoViewData(
            title: activity.type ?? "Activity",
            startTime: calendarRepository.getTime(from: activity.startDate),
            elapsedTime: calendarRepository.formatInterval(from: activity.startDate, to: activity.endDate ?? activity.startDate) ?? "",
            distanceInKilometers: Measurement(value: activity.distince, unit: .meters).converted(to: UnitLength.kilometers),
        )
    }
    
}
