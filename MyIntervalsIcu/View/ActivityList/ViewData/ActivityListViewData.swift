//
//  ActivityListViewData.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 9/23/26.
//

import Foundation

struct ActivityListViewData : Identifiable {
    
    let activities: [ActivityListSummary]
    let activityDate: Date
    
    struct ActivityListSummary : Identifiable {
        let id: String
        let summaryInfoViewData: ActivitySummaryInfoViewData
        let summaryChartBars: [SummaryBar]
    }
    
    struct SummaryBar : Identifiable {
        let id: String
        let widthPercentage: CGFloat
        let heightPercentage: CGFloat
        let zone: Int
    }
    
    var id: Date {
        activityDate
    }
    
}
