//
//  DataModule.swift
//  MyIntervalsIcu
//
//  Created by Michael Rogers on 11/13/25.
//

import Blade
import Foundation

@Module()
enum DataModule {
    
    @Provider
    static func provideActivityDao() -> ActivityDao {
        ActivityDao.shared
    }
    
}
