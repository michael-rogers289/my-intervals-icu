//
//  ActivityRepositoryModule.swift
//  MyIntervalsIcu
//
//  Created by Michael Rogers on 11/13/25.
//

import FactoryKit
import Foundation

extension Container {
    
    var activityRepository: Factory<ActivityRepository> {
        self {
            ActivityRepository(
                activityDao: Container.shared.activityDao.resolve(),
                networkManager: Container.shared.networkManager.resolve(),
                calendarRepository: Container.shared.calendarRepository.resolve()
            )
        }
    }
    
    var calendarRepository: Factory<CalendarRepository> {
        self {
            LiveCalendarRepository()
        }
    }
    
}
