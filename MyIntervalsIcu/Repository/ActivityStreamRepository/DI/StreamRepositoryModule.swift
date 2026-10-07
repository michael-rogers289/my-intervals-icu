//
//  StreamRepositoryModule.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/4/26.
//

import FactoryKit

extension Container {
    
    var streamRepository: Factory<ActivityStreamRepository> {
        self {
            ActivityStreamRepository(
                networkManager: Container.shared.networkManager.resolve(),
                streamDao: Container.shared.streamDao.resolve()
            )
        }
    }
    
}
