//
//  GearDto.swift
//  MyIntervalsIcu
//
//  Created by Michael Rogers on 11/9/25.
//

import CodingKeysMacro
import Foundation

@CodingKeys(.all)
struct GearDto : Codable {
    let id: String
    let name: String?
    let distance: Double?
    let primary: Bool?
}
