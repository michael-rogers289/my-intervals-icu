//
//  ZoneSummaryViewData.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 9/12/26.
//

import SwiftUI
import Foundation

struct ZoneSummaryViewData : Identifiable {
    
    enum SummaryType : CaseIterable {
        case percent
        case absolute
        
        var title: String {
            switch self {
            case .absolute: "Time in Zone (Seconds)"
            case .percent: "Percent in Zone"
            }
        }
    }
    
    let id: Int
    let zoneTitle: String
    let summaryType: SummaryType
    let value: Double
    
    var zoneColor: Color {
        return switch id {
        case 0: .gray
        case 1: .teal
        case 2: .blue
        case 3: .green
        case 4: .yellow
        case 5: .orange
        case 6: .red
        case 7: .purple
        default: .gray
        }
    }
    
    init(
        zoneSummary: ZoneSummary,
        summaryType: SummaryType,
    ) {
        self.id = zoneSummary.zone
        self.zoneTitle = "Zone \(zoneSummary.zone)"
        self.summaryType = summaryType
        self.value = switch summaryType {
        case .absolute:
            Double(zoneSummary.secondsInZone)
        case .percent:
            zoneSummary.percentInZone
        }
    }
    
    
}
