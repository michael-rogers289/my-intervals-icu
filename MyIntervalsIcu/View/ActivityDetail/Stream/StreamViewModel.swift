//
//  StreamViewModel.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/4/26.
//

import FactoryKit
import SwiftUI

@MainActor
@Observable
final class StreamViewModel {
    
    // MARK: Private Variables
    
    private let networkManager = Container.shared.networkManager
    var selectedActivityStreams: [StreamViewData] = []
    
    private let activityId: String
    
    // MARK: Life Cycle
    
    init(activityId: String) {
        self.activityId = activityId
        self.selectedActivityStreams = selectedActivityStreams
    }
    
}
