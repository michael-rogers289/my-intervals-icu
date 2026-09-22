//
//  Array+DatabaseExtensions.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 9/4/26.
//

import Foundation
import GRDB

extension Array where Element: PersistableRecord {
    
    func insertAll(in database: Database) throws {
        try self.forEach { try $0.insert(database, onConflict: .replace) }
    }
    
}
