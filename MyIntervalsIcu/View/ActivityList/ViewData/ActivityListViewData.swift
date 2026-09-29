//
//  ActivityListViewData.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 9/23/26.
//

import Foundation

enum ActivityListViewData : Identifiable {
    
    case section(activities: [ActivityListSummary], sectionDate: Date)
    case activity(activity: ActivityListSummary)
    
    struct ActivityListSummary : Identifiable {
        let id: String
        let title: String
        let date: Date
        let elapsedTime: Measurement<UnitDuration>
        let distance: Measurement<UnitLength>
        let summaryChartBars: [SummaryBar]
    }
    
    struct SummaryBar : Identifiable {
        let id: String
        let widthPercentage: CGFloat
        let heightPercentage: CGFloat
        let zone: Int
    }
    
    var id: String {
        switch self {
        case .activity(let activity): activity.id
        case .section(let activities, _): activities.map { $0.id }.joined(separator: "_")
        }
    }
    
}
