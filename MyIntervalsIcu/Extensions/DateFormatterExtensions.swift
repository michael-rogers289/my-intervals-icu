//
//  DateFormatterExtensions.swift
//  MyIntervalsIcu
//
//  Created by Michael Rogers on 11/13/25.
//

import Foundation

struct StandardFormatter: @unchecked Sendable {
    
    private let standard: ISO8601DateFormatter = {
        var formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter
    }()
    
    func format(_ date: Date) -> String {
        standard.string(from: date)
    }
    
}
