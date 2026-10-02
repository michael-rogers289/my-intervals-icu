//
//  NetworkDependencyModule.swift
//  MyIntervalsIcu
//
//  Created by Michael Rogers on 11/13/25.
//

import FactoryKit
import Foundation

extension Container {
    
    var networkSession: Factory<NetworkSession> {
        self {
            URLSession(
                configuration: URLSessionConfiguration.default
            )
        }.singleton
    }
    
    var networkLogger: Factory<NetworkLogging> {
        self {
            NetworkLogger()
        }
    }
    
    var networkManager: Factory<NetworkManager> {
        self {
            NetworkManager(
                networkLogger: Container.shared.networkLogger.resolve(),
                networkSession: Container.shared.networkSession.resolve(),
                calendarRepository: Container.shared.calendarRepository.resolve()
            )
        }.singleton
    }
    
}
