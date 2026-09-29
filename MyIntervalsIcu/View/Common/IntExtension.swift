//
//  IntExtension.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 9/29/26.
//

import Foundation
import SwiftUI

extension Int {
    
    var zoneColor: Color {
        return switch self {
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
    
}
