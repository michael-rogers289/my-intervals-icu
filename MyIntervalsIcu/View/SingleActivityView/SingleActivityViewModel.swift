//
//  SingleActivityViewModel.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 9/15/26.
//

import Foundation

@Observable
@MainActor
final class SingleActivityViewModel {
    
    // MARK: Private Variables
    private let activityRepository = BladeMyIntervalsIcuComponent().activityRepository()
    private let activityId: String
    
    // MARK: Init
    init(activityId: String) {
        self.activityId = activityId
    }
    
}
