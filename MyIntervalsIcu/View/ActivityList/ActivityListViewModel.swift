//
//  ActivityListViewModel.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 9/23/26.
//

import Combine
import Foundation
import SwiftUI

@MainActor
@Observable
final class ActivityListViewModel {
    
    // MARK: Private Variables
    private let activityRepository: ActivityRepository = BladeMyIntervalsIcuComponent().activityRepository()
    private var currentMonth: DateInterval
    private var refreshTask: Task<Void, Never>?
    private var cancellables: Set<AnyCancellable> = []
    
    //MARK: Public Variables
    private(set) var activities: [Activity] = []
    
    // MARK: Init
    init() {
        do {
            currentMonth = try CalendarRepository.getCurrentMonth(from: Date())
            print("CURRENT MONTH: \(currentMonth)")
        } catch {
            fatalError("Unable to create date for current week")
        }
    }
    
    // MARK: Public Methods
    func startObservation() {
        refresh()
        cancellables.removeAll()
        activityRepository.getActivities(for: currentMonth)
            .replaceError(with: [])
            .sink { [weak self] activities in
                self?.activities = activities
            }
            .store(in: &cancellables)
    }
    
    //MARK: Private Methods
    private func refresh() {
        let currentMonth = currentMonth
        refreshTask = Task { [weak self] in
            defer {
                self?.refreshTask = nil
            }
            do {
                try await self?.activityRepository.fetchActivitiesForDateRange(range: currentMonth)
            } catch {
                print("Got error from network: \(error)")
            }
        }
    }
}
    
