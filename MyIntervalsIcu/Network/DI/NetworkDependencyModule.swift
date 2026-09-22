//
//  NetworkDependencyModule.swift
//  MyIntervalsIcu
//
//  Created by Michael Rogers on 11/13/25.
//

import Blade
import Foundation

@Module()
enum NetworkDependencyModule {
    
    @Provider
    static func providesNetworkManager() -> NetworkManager {
        NetworkManager()
    }
    
}
