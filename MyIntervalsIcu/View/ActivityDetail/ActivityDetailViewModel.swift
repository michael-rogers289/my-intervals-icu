//
//  ActivityDetailViewModel.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 9/30/26.
//

import Combine
import FactoryKit
import Foundation
import SwiftUI

@Observable
@MainActor
final class ActivityDetailViewModel {
    
    //MARK: Private Properties
    private let id: String
    
    @ObservationIgnored
    @Injected(\.activityRepository)
    private var activityRepository
    private let activityMapper = ActivityMapper()
    private var cancellables: Set<AnyCancellable> = []
    
    //MARK: Public Properties
    private(set) var summaryInfo: ActivitySummaryInfoViewData?
    
    //MARK: Initialization
    init(id: String) {
        self.id = id
    }
    
    //MARK: Public Methods
    func startObservation() {
        activityRepository
            .getActivity(byId: id)
            .replaceError(with: nil)
            .sink { [weak self] activity in
                guard let activity else {
                    self?.summaryInfo = nil
                    return
                }
                self?.summaryInfo = self?.activityMapper.map(activity: activity)
            }
            .store(in: &cancellables)
    }
    
}
