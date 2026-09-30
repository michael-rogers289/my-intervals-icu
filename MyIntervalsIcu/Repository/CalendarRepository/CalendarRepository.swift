//
//  CalendarRepository.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 8/30/26.
//

import Foundation

enum CalendarError : Error {
    case dateCreationError
}

struct CalendarRepository {
    
    enum WeekStartEndConfiguration {
        case startingAt(date: Date)
        case endingAt(date: Date)
        
        var date: Date {
            switch self {
            case .endingAt(let date),
                .startingAt(let date): date
            }
        }
        
        var endWeekDays: Int {
            switch self {
            case .endingAt: -7
            case .startingAt: 7
            }
        }
    }
    
    nonisolated(unsafe) private static let standard: ISO8601DateFormatter = {
        var formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter
    }()
    
    private static let dateIntervalFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .brief
        formatter.allowsFractionalUnits = true
        return formatter
    }()
    
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    private static let calendar = Calendar.current
    
    static func getWeek(by configuration: WeekStartEndConfiguration = .startingAt(date: Date()) ) throws(CalendarError) -> DateInterval {
        guard let startOfWeek = startOfWeek(for: configuration.date),
              let endOfWeek = calendar.date(byAdding: .day, value: configuration.endWeekDays, to: configuration.date) else {
            throw CalendarError.dateCreationError
        }
        return switch configuration {
            case .endingAt: DateInterval(start: endOfWeek, end: startOfWeek)
            case .startingAt: DateInterval(start: startOfWeek, end: endOfWeek)
            }
    }
    
    static func getCurrentMonth(from date: Date) throws(CalendarError) -> DateInterval {
        guard let monthInterval = calendar.dateInterval(of: .month, for: date) else {
            throw CalendarError.dateCreationError
        }
        return monthInterval
    }
    
    static func startOfWeek(for date: Date) -> Date? {
        calendar.date(
            from: calendar.dateComponents(
                [.yearForWeekOfYear, .weekOfYear],
                from: date
            )
        )
    }
    
    static func startOfDay(on date: Date) -> Date {
        calendar.startOfDay(for: date)
    }
    
    static func date(byAddingSeconds seconds: Int, to start: Date) -> Date? {
        calendar.date(byAdding: .second, value: seconds, to: start)
    }
    
    static func iso8601Format(_ date: Date) -> String {
        unsafe standard.string(from: date)
    }
    
    static func formatInterval(from start: Date, to end: Date) -> String? {
        dateIntervalFormatter.string(from: start, to: end)
    }
    
    static func getTime(from date: Date) -> String {
        timeFormatter.string(from: date)
    }
}
