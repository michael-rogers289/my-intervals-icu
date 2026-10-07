//
//  ActivityNavigationViewModel.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 9/23/26.
//

import FactoryKit
import Foundation

enum ActivityNavigationElement: Hashable {
    case detail
}

@MainActor
@Observable
class ActivityNavigationViewModel : NavigationViewModel {
    
    var stack: [ActivityNavigationElement] = []
    
    func pushDetail(with activityId: Activity.ActivityId) {
        Container.shared.detailActivityIdSelector.register {
            activityId
        }
        self.push(.detail)
    }
    
}
