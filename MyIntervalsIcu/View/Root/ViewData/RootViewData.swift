//
//  RootViewData.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 8/30/26.
//

import Foundation

enum RootViewData: CaseIterable {
    case home
    case summary
    case settings
    
    var title: String {
        switch self {
        case .home: "Home"
        case .settings: "Settings"
        case .summary: "Summary"
        }
    }
    
    var iconIdentifier: String {
        switch self {
        case .home: "house.fill"
        case .settings: "gear"
        case .summary: "chart.bar.fill"
        }
    }
}
