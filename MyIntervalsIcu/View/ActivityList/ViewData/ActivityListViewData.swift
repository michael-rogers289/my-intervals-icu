//
//  ActivityListViewData.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 9/23/26.
//

import Foundation

enum ActivityListViewData {
    
    case section(activities: [Activity])
    case activity(activity: Activity)
    
    struct Activity {
        let title: String
        let date: Date
    }
    
}
