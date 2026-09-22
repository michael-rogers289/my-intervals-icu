//
//  DataBaseQueueExtensions.swift
//  MyIntervalsIcu
//
//  Created by Michael Rogers on 11/14/25.
//

import Foundation
import GRDB
import GRDBSQLite

nonisolated
extension DatabaseQueue {
    
    enum Tables: String {
        case activity = "Activity"
        case activityPowerZone = "ActivityPowerZone"
        case activityheartRateZone = "ActivityHeartRateZone"
    }
    
    func createTables() throws {
        try write { database in
            try createActivityTable(with: database)
            try createActivityPowerZoneTable(with: database)
            try createActivityHeartRateZoneTable(with: database)
        }
    }
    
    private func createActivityTable(with database: Database) throws {
        guard try !database.tableExists(Tables.activity.rawValue) else { return }
        
        try database.create(table: Tables.activity.rawValue) { table in
            table.column(Activity.codingKey(for: \.id))
                .notNull()
                .primaryKey(onConflict: .replace)
                .indexed()
            table.column(Activity.codingKey(for: \.distince)).notNull()
            table.column(Activity.codingKey(for: \.startDate)).notNull().indexed()
        }
    }
    
    private func createActivityPowerZoneTable(with database: Database) throws {
        guard try !database.tableExists(Tables.activityPowerZone.rawValue) else { return }
        try database.create(table: Tables.activityPowerZone.rawValue) { table in
            table.column(ActivityPowerZone.codingKey(for: \.id), .text)
                .primaryKey(onConflict: .replace)
                .notNull()
                .indexed()
            table.column(ActivityPowerZone.codingKey(for: \.zone), .integer)
                .notNull()
                .indexed()
            table.column(ActivityPowerZone.codingKey(for: \.secondsInZone), .integer)
                .notNull()
            table.column(ActivityPowerZone.codingKey(for: \.activityId), .text)
                .notNull()
                .indexed()
        }
    }
    
    private func createActivityHeartRateZoneTable(with database: Database) throws {
        guard try !database.tableExists(Tables.activityheartRateZone.rawValue) else { return }
        
        try database.create(table: Tables.activityheartRateZone.rawValue) { table in
            table.column(ActivityHeartRateZone.codingKey(for: \.id), .text)
                .primaryKey(onConflict: .replace)
                .notNull()
                .indexed()
            table.column(ActivityHeartRateZone.codingKey(for: \.zone), .integer)
                .notNull()
                .indexed()
            table.column(ActivityHeartRateZone.codingKey(for: \.secondsInZone), .integer)
                .notNull()
            table.column(ActivityHeartRateZone.codingKey(for: \.activityId), .text)
                .notNull()
                .indexed()
            table.column(ActivityHeartRateZone.codingKey(for: \.upperBound), .integer)
                .notNull()
            table.column(ActivityHeartRateZone.codingKey(for: \.lowerBound), .integer)
                .notNull()

        }
    }
    
}
