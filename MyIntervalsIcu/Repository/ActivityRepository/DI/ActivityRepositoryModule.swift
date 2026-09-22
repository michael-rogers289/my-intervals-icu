//
//  ActivityRepositoryModule.swift
//  MyIntervalsIcu
//
//  Created by Michael Rogers on 11/13/25.
//

import Blade
import Foundation

@Module()
enum ActivityRepositoryModule {
    
    @Provider
    static func provideActivyRepository(
        dao: ActivityDao,
        networkManager: NetworkManager
    ) -> ActivityRepository {
        ActivityRepository(activityDao: dao, networkManager: networkManager)
    }
    
}
