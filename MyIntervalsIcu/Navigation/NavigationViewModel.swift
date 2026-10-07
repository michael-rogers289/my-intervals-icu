//
//  NavigationViewModel.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 9/23/26.
//

import Foundation

@MainActor
protocol NavigationViewModel : AnyObject {
    
    associatedtype NavigationElement : Equatable
    
    var stack: [NavigationElement] { get set }
    
    func push(_ element: NavigationElement)
    
    func pop()
    
    func pop(upTo element: NavigationElement) -> Bool

    func popToRoot() -> Bool
    
}

@MainActor
extension NavigationViewModel {
    
    func push(_ element: NavigationElement) {
        stack.append(element)
    }
    
    func pop() {
        stack.removeLast()
    }
    
    @discardableResult
    func pop(upTo element: NavigationElement) -> Bool {
        guard let lastIndex = stack.lastIndex(where: { $0 == element }) else {
            return false
        }
        stack.removeSubrange(lastIndex...)
        return true
    }
    
    func popToRoot() -> Bool {
        guard stack.count > 1 else { return false }
        stack.removeSubrange(1...)
        return true
    }
    
}
