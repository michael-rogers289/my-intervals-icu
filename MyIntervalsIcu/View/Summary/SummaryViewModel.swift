//
//  SummaryViewModel.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 8/30/26.
//

import Combine
import FactoryKit
import Foundation
import GRDB

@MainActor
var count = 0

@MainActor
@Observable
class SummaryViewModel {
    
    // MARK: Private Variables
    @ObservationIgnored
    private var activityRepository = Container.shared.activityRepository.resolve()
    
    @ObservationIgnored
    private var calendarRepository = Container.shared.calendarRepository.resolve()
    
    private var currentWeek: DateInterval
    private var refreshTask: Task<Void, Never>?
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: Public Variables
    private(set) var heartRateSummaries: [ZoneSummaryViewData] = []
    private(set) var powerSummaries: [ZoneSummaryViewData] = []
    private(set) var distanceForWeek: Double = Double.zero
    
    @Published
    @ObservationIgnored
    var summaryType: ZoneSummaryViewData.SummaryType = .percent
    
    var weekEnding: Date {
        currentWeek.end
    }
    
    // MARK: Init
    
    init() {
        do {
            currentWeek = try calendarRepository.getWeek(by: .startingAt(date: Date()))
        } catch {
            fatalError("Unable to create date for current week")
        }
    }
        
    // MARK: Public Methods
    func startObservation() {
        refresh()
        cancellables.removeAll()
        activityRepository.getHeartRateZonesGroupedByZone(for: currentWeek)
            .replaceError(with: [])
            .combineLatest($summaryType)
            .map { zoneSummaries, summaryType in
                zoneSummaries.map { ZoneSummaryViewData(zoneSummary: $0, summaryType: summaryType) }
            }
            .sink { [weak self] summary in self?.heartRateSummaries = summary }
            .store(in: &cancellables)
        activityRepository.getPowerZonesGroupedByZone(for: currentWeek)
            .replaceError(with: [])
            .combineLatest($summaryType)
            .map { zoneSummaries, summaryType in
                zoneSummaries.map { ZoneSummaryViewData(zoneSummary: $0, summaryType: summaryType) }
            }
            .sink { [weak self] summary in self?.powerSummaries = summary }
            .store(in: &cancellables)
        activityRepository.getDistanceSummaryByDayBetween(for: currentWeek)
            .replaceError(with: Double.zero)
            // distance is stored in meters and we'd like to format to KM
            .sink { [weak self] in self?.distanceForWeek = $0 / 1000.0 }
            .store(in: &cancellables)
    }
    
    func nextWeek() {
        updateCurrentWeek(by: .startingAt(date: currentWeek.end))
        startObservation()
    }
    
    func previousWeek() {
        updateCurrentWeek(by: .endingAt(date: currentWeek.start))
        startObservation()
    }
    
    func refresh() {
        let currentWeekRange = currentWeek
        refreshTask = Task { [weak self] in
            defer {
                await MainActor.run {
                    self?.refreshTask = nil
                }
            }
            do {
                try await self?.activityRepository.fetchActivitiesForDateRange(range: currentWeekRange)
            } catch {
                print("Got error from network: \(error)")
            }
        }
    }
    
    // MARK: Private Methods
    
    private func updateCurrentWeek(by configuration: WeekStartEndConfiguration) {
        do {
            currentWeek = try calendarRepository.getWeek(by: configuration)
        } catch {
            print("Unable to create date starting at \(configuration.date)")
        }
    }
}
