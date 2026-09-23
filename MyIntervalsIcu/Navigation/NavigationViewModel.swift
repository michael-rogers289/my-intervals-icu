//
//  NavigationViewModel.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 9/23/26.
//

import Foundation

@MainActor
protocol NavigationViewModel {
    
    associatedtype NavigationElement : Equatable
    
    var stack: [NavigationElement] { get set }
    
    mutating func push(_ element: NavigationElement)
    
    mutating func pop()
    
    mutating func pop(upTo element: NavigationElement) -> Bool

    mutating func popToRoot() -> Bool
    
}

@MainActor
extension NavigationViewModel {
    
    mutating func push(_ element: NavigationElement) {
        stack.append(element)
    }
    
    mutating func pop() {
        stack.removeLast()
    }
    
    @discardableResult
    mutating func pop(upTo element: NavigationElement) -> Bool {
        guard let lastIndex = stack.lastIndex(where: { $0 == element }) else {
            return false
        }
        stack.removeSubrange(lastIndex...)
        return true
    }
    
    mutating func popToRoot() -> Bool {
        guard stack.count > 1 else { return false }
        stack.removeSubrange(1...)
        return true
    }
    
}
