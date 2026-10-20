//
//  ActivityCoordinateRepositoryModule.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/20/26.
//

import FactoryKit

extension Container {

    var activityCoordinateRepository: Factory<ActivityCoordinateRepository> {
        self {
            ActivityCoordinateRepository(
                networkManager: Container.shared.networkManager.resolve(),
                activityCoordinateDao: Container.shared.activityCoordinateDao.resolve()
            )
        }
    }

}
