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

enum WeekStartEndConfiguration {
    case startingAt(date: Date)
    case endingAt(date: Date)
    
    var date: Date {
        switch self {
        case .endingAt(let date), .startingAt(let date): date
        }
    }
    
    var endWeekDays: Int {
        switch self {
        case .endingAt: -7
        case .startingAt: 7
        }
    }
}

protocol CalendarRepository : Sendable {
    func getWeek(by configuration: WeekStartEndConfiguration) throws(CalendarError) -> DateInterval
    func getCurrentMonth(from date: Date) throws(CalendarError) -> DateInterval
    func startOfDay(on date: Date) -> Date
    func date(byAddingSeconds seconds: Int, to start: Date) -> Date?
    func iso8601Format(_ date: Date) -> String
    func formatInterval(from start: Date, to end: Date) -> String?
    func getTime(from date: Date) -> String
}

struct LiveCalendarRepository : CalendarRepository {
    
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
    
func getWeek(by configuration: WeekStartEndConfiguration = .startingAt(date: Date()) ) throws(CalendarError) -> DateInterval {
        guard let startOfWeek = Self.startOfWeek(for: configuration.date),
              let endOfWeek = Self.calendar.date(byAdding: .day, value: configuration.endWeekDays, to: configuration.date) else {
            throw CalendarError.dateCreationError
        }
        return switch configuration {
        case .endingAt: DateInterval(start: endOfWeek, end: startOfWeek)
        case .startingAt: DateInterval(start: startOfWeek, end: endOfWeek)
        }
    }
    
    func getCurrentMonth(from date: Date) throws(CalendarError) -> DateInterval {
        guard let monthInterval = Self.calendar.dateInterval(of: .month, for: date) else {
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
    
    func startOfDay(on date: Date) -> Date {
        Self.calendar.startOfDay(for: date)
    }
    
    func date(byAddingSeconds seconds: Int, to start: Date) -> Date? {
        Self.calendar.date(byAdding: .second, value: seconds, to: start)
    }
    
    func iso8601Format(_ date: Date) -> String {
        unsafe Self.standard.string(from: date)
    }
    
    func formatInterval(from start: Date, to end: Date) -> String? {
        Self.dateIntervalFormatter.string(from: start, to: end)
    }
    
    func getTime(from date: Date) -> String {
        Self.timeFormatter.string(from: date)
    }
}
