//
//  ActivityNavigationViewModel.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 9/23/26.
//

import Foundation

enum ActivityNavigationElement: Hashable {
    case detail(activityId: String)
}

@MainActor
@Observable
class ActivityNavigationViewModel : NavigationViewModel {
    
    var stack: [ActivityNavigationElement] = []
    
}
