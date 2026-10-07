//
//  DataModule.swift
//  MyIntervalsIcu
//
//  Created by Michael Rogers on 11/13/25.
//

import FactoryKit
import Foundation
import GRDB

extension Container {
    
    var activityDao: Factory<ActivityDao> {
        self {
            ActivityDao(
                databaseQueue: Container.shared.databaseQueue.resolve(),
                calendarRepository: Container.shared.calendarRepository.resolve()
            )
        }.singleton
    }
    
    var streamDao: Factory<StreamDao> {
        self {
            StreamDao(databaseQueue: Container.shared.databaseQueue.resolve())
        }.singleton
    }
    
    var databaseQueue: Factory<DatabaseQueue> {
        self {
#if DEBUG
        let inMemoryDatabase = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
#else
        let inMemoryDatabase = false
#endif
        
        do {
            if inMemoryDatabase {
                return try DatabaseQueue(named: "com.myintervalsicu.database.sqlite")
            } else {
                let defaultFileManager = FileManager.default
                
                let userDirectory = try FileManager.default.url(
                    for: .documentDirectory,
                    in: .userDomainMask,
                    appropriateFor: nil,
                    create: true,
                )
                // recommended to add file to directory for encryption / backup purposes
                let databaseDirectory = userDirectory.appending(path: "database")
                
                if !defaultFileManager.fileExists(atPath: databaseDirectory.path()) {
                    try FileManager.default.createDirectory(at: databaseDirectory, withIntermediateDirectories: true)
                }
                
                return try DatabaseQueue(
                    path: databaseDirectory
                        .appendingPathComponent("myintervals.sqlite")
                        .path(),
                    configuration: Configuration()
                )
            }
        } catch {
            fatalError("Unable to spin up database \(error)")
        }
        }.singleton
    }
    
}
