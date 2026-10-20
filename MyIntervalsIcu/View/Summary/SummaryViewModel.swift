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
    private let activityRepository = Container.shared.activityRepository.resolve()

    @ObservationIgnored
    private let calendarRepository = Container.shared.calendarRepository.resolve()

    @ObservationIgnored
    private let viewLogger = Container.shared.viewLogger.resolve()

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
            viewLogger.logError(message: "CalendarRepository unable to create date for current week \(error)")
            fatalError("Unable to create date for current week")
        }
    }

    // MARK: Public Methods
    func startObservation() {
        refresh()
        cancellables.removeAll()
        activityRepository.getHeartRateZonesGroupedByZone(for: currentWeek)
            .combineLatest($summaryType.setFailureType(to: Error.self))
            .map { zoneSummaries, summaryType in
                zoneSummaries.map { ZoneSummaryViewData(zoneSummary: $0, summaryType: summaryType) }
            }
            .sink { [weak self] in
                self?.viewLogger.logError(message: "Failed to get heart rate zones \($0)")
            } onReceieveValue: { [weak self] summary in self?.heartRateSummaries = summary }
            .store(in: &cancellables)
        activityRepository.getPowerZonesGroupedByZone(for: currentWeek)
            .combineLatest($summaryType.setFailureType(to: Error.self))
            .map { zoneSummaries, summaryType in
                zoneSummaries.map { ZoneSummaryViewData(zoneSummary: $0, summaryType: summaryType) }
            }
            .sink { [weak self] in
                self?.viewLogger.logError(message: "Failed to get power zones \($0)")
            } onReceieveValue: { [weak self] summary in self?.powerSummaries = summary }
            .store(in: &cancellables)
        activityRepository.getDistanceSummaryByDayBetween(for: currentWeek)
            // distance is stored in meters and we'd like to format to KM
            .sink { [weak self] in
                self?.viewLogger.logError(message: "Failed to get distance \($0)")
            } onReceieveValue: { [weak self] in self?.distanceForWeek = $0 / 1000.0 }
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
                self?.viewLogger.logError(message: "Got error from network: \(error)")
            }
        }
    }

    // MARK: Private Methods

    private func updateCurrentWeek(by configuration: WeekStartEndConfiguration) {
        do {
            currentWeek = try calendarRepository.getWeek(by: configuration)
        } catch {
            viewLogger.logError(message: "Unable to create date starting at \(configuration.date)")
        }
    }
}
