//
//  MyIntervalsIcuComponent.swift
//  MyIntervalsIcu
//
//  Created by Michael Rogers on 11/13/25.
//

import Blade
import Foundation

@Component(modules: [NetworkDependencyModule.self, DataModule.self, ActivityRepositoryModule.self])
protocol MyIntervalsIcuComponent {
    func activityRepository() -> ActivityRepository
}
