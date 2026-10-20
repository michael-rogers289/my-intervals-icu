//
//  ViewLogger.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/20/26.
//

import Foundation
import OSLog

protocol ViewLogging {
    func logDebug(file: StaticString, line: UInt, message: @escaping @autoclosure () -> String)
    func logError(file: StaticString, line: UInt, message: @escaping @autoclosure () -> String)
}

extension ViewLogging {
    func logDebug(file: StaticString = #file, line: UInt = #line, message: @autoclosure () -> String) {}
    func logError(file: StaticString = #file, line: UInt = #line, message: @autoclosure () -> String) {}
}

struct ViewLogger: ViewLogging {

#if DEBUG
    private static let isDebuggable = true
#else
    private static let isDebuggable = false
#endif

    private static let logger = Logger(subsystem: "com.mike.myintervalsicu", category: "View")

    func logDebug(file: StaticString = #file, line: UInt = #line, message: @escaping @autoclosure () -> String) {
        guard Self.isDebuggable else { return }
        Self.logger.debug("\(file):\(line) - \(message())")
    }

    func logError(file: StaticString = #file, line: UInt = #line, message: @escaping @autoclosure () -> String) {
        Self.logger.error("\(file):\(line) - \(message())")
    }
}
