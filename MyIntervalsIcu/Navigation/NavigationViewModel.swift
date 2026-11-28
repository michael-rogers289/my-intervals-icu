//
//  NavigationViewModel.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 9/23/26.
//

import FactoryKit
import SwiftUI

@MainActor
@Observable
final class NavigationViewModel: AnyObject {

    typealias Element = Hashable & Equatable

    var stack: NavigationPath = NavigationPath()

    func push<E: Element>(_ element: E) {
        stack.append(element)
    }

    func pop() {
        stack.removeLast()
    }

    func popToRoot() -> Bool {
        guard stack.count > 1 else { return false }
        stack.removeLast(stack.count - 1)
        return true
    }

    func pushActivityDetail(with activityId: Activity.ActivityId) {
        Container.shared.detailActivityIdSelector.register {
            activityId
        }
        self.push(ActivityNavigationElement.detail)
    }

}
