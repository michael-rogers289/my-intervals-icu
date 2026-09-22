//
//  SummaryView.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 8/30/26.
//

import SwiftUI
import Charts

struct SummaryView: View {
    
    @State private var viewModel = SummaryViewModel()
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(alignment: .center, spacing: .spacingSmall) {
                    DateSelector(
                        totalDistance: viewModel.distanceForWeek,
                        displayDate: viewModel.weekEnding,
                        onPreviousSelected: viewModel.previousWeek,
                        onNextSelected: viewModel.nextWeek
                    )
                    SummaryTypePicker(selectedSummaryType: $viewModel.summaryType)
                    SummaryBarView(
                        title: "Power Zone Summary",
                        selectedType: viewModel.summaryType,
                        zoneSummaries: viewModel.powerSummaries
                    )
                    Divider()
                    SummaryBarView(
                        title: "Heart Rate Zone Summary",
                        selectedType: viewModel.summaryType,
                        zoneSummaries: viewModel.heartRateSummaries
                    )
                }
                .padding([.top, .leading, .trailing], .spacingMedium)
            }
        }
        .onAppear { viewModel.startObservation() }
        .navigationTitle(Text("Weekly Summary"))
    }
}

private struct SummaryTypePicker: View {
    
    @Binding var selectedSummaryType: ZoneSummaryViewData.SummaryType
    
    var body: some View {
        Picker("Type", selection: $selectedSummaryType) {
            ForEach(ZoneSummaryViewData.SummaryType.allCases, id: \.self) {
                Text($0.title).tag($0)
            }
        }
        .pickerStyle(.segmented)
        .labelsHidden()
    }
    
}

private struct SummaryBarView: View {
    
    let title: String
    let selectedType: ZoneSummaryViewData.SummaryType
    let zoneSummaries: [ZoneSummaryViewData]
    
    var body: some View {
        VStack(
            alignment: .center,
            spacing: .spacingMedium
        ) {
            Text(title).font(.title)
            Chart(zoneSummaries) { summary in
                BarMark(
                    x: .value("zone", summary.zoneTitle),
                    y: .value("zone_value", summary.value),
                )
                .foregroundStyle(summary.zoneColor)
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { value in
                    AxisGridLine().foregroundStyle(.clear) // no vertical grids
                    AxisTick()
                    AxisValueLabel().font(.caption)
                }
            }
            .chartYAxisLabel(selectedType.title)
        }
        .padding(.spacingMedium)
        .aspectRatio(1.0 / 1.5, contentMode: .fit)
    }
     
}

#Preview {
    SummaryBarView(
        title: "Heart Rate Summary",
        selectedType: .percent,
        zoneSummaries: [
            ZoneSummaryViewData(
                zoneSummary: ZoneSummary(zone: 0, secondsInZone: 100, percentInZone: 0.2),
                summaryType: .absolute
            ),
            ZoneSummaryViewData(
                zoneSummary: ZoneSummary(zone: 1, secondsInZone: 100, percentInZone: 0.2),
                summaryType: .absolute
            ),
            ZoneSummaryViewData(
                zoneSummary: ZoneSummary(zone: 2, secondsInZone: 100, percentInZone: 0.2),
                summaryType: .absolute
            ),
            ZoneSummaryViewData(
                zoneSummary: ZoneSummary(zone: 3, secondsInZone: 100, percentInZone: 0.2),
                summaryType: .absolute
            ),
            ZoneSummaryViewData(
                zoneSummary: ZoneSummary(zone: 4, secondsInZone: 100, percentInZone: 0.2),
                summaryType: .absolute
            ),
            ZoneSummaryViewData(
                zoneSummary: ZoneSummary(zone: 5, secondsInZone: 100, percentInZone: 0.2),
                summaryType: .absolute
            ),
            ZoneSummaryViewData(
                zoneSummary: ZoneSummary(zone: 6, secondsInZone: 100, percentInZone: 0.2),
                summaryType: .absolute
            ),
            ZoneSummaryViewData(
                zoneSummary: ZoneSummary(zone: 7, secondsInZone: 100, percentInZone: 0.2),
                summaryType: .absolute
            ),
        ]
    )
}
