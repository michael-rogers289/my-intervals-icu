//
//  DataBaseQueueExtensions.swift
//  MyIntervalsIcu
//
//  Created by Michael Rogers on 11/14/25.
//

import Foundation
import GRDB
import GRDBSQLite
import SqlDsl

nonisolated
extension DatabaseQueue {
    
    enum Tables: String {
        case activity = "Activity"
        case summaryChartBar = "SummaryChartBar"
        case activityPowerZone = "ActivityPowerZone"
        case activityheartRateZone = "ActivityHeartRateZone"
    }
    
    func createTables() throws {
        try write { database in
            try createActivityTable(with: database)
            try createActivityPowerZoneTable(with: database)
            try createActivityHeartRateZoneTable(with: database)
            try createSummaryChartBarTable(with: database)
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
            table.column(Activity.codingKey(for: \.endDate))
            table.column(Activity.codingKey(for: \.elapsedTime))
            table.column(Activity.codingKey(for: \.type))
            table.column(Activity.codingKey(for: \.averageCadence))
            table.column(Activity.codingKey(for: \.calories))
            table.column(Activity.codingKey(for: \.polarizationIndex))
            table.column(Activity.codingKey(for: \.maxSpeed))
            table.column(Activity.codingKey(for: \.averageSpeed))
            table.column(Activity.codingKey(for: \.normalizedWatts))
            table.column(Activity.codingKey(for: \.icuAverageWatts))
            table.column(Activity.codingKey(for: \.deviceWatts))
            table.column(Activity.codingKey(for: \.maxHeartRate))
            table.column(Activity.codingKey(for: \.averageHeartRate))
        }
    }
    
    private func createSummaryChartBarTable(with database: Database) throws {
        guard try !database.tableExists(Tables.summaryChartBar.rawValue) else { return }
        
        try database.create(table: Tables.summaryChartBar.rawValue) { table in
            table.column(SummaryChartBar.codingKey(for: \.id))
                .primaryKey(onConflict: .replace)
                .indexed()
            table.column(SummaryChartBar.codingKey(for: \.xChartPosition))
                .notNull()
            table.column(SummaryChartBar.codingKey(for: \.width))
                .notNull()
            table.column(SummaryChartBar.codingKey(for: \.intensity))
                .notNull()
            table.column(SummaryChartBar.codingKey(for: \.zone))
                .notNull()
            table.column(SummaryChartBar.codingKey(for: \.activityId))
                .notNull()
                .indexed()
            table.column(SummaryChartBar.codingKey(for: \.totalNumZones))
                .notNull()
            table.foreignKey(
                [SummaryChartBar.codingKey(for: \.activityId)],
                references: Tables.activity.rawValue,
                columns: [Activity.codingKey(for: \.id)],
                onDelete: .cascade,
                onUpdate: .cascade
            )
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
            
            table.foreignKey(
                [ActivityPowerZone.codingKey(for: \.activityId)],
                references: Tables.activity.rawValue,
                columns: [Activity.codingKey(for: \.id)],
                onDelete: .cascade,
                onUpdate: .cascade
            )
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
            
            table.foreignKey(
                [ActivityHeartRateZone.codingKey(for: \.activityId)],
                references: Tables.activity.rawValue,
                columns: [Activity.codingKey(for: \.id)],
                onDelete: .cascade,
                onUpdate: .cascade
            )
        }
    }
    
}

