//
//  RootView.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 8/30/26.
//

import SwiftUI

struct RootView: View {
    
    @State private var selection: RootViewData = .home
    
    var body: some View {
        TabView(selection: $selection) {
            Tab(RootViewData.home.title, systemImage: RootViewData.home.iconIdentifier, value: RootViewData.home) {
                ActivityListView()
            }
            Tab(RootViewData.summary.title, systemImage: RootViewData.summary.iconIdentifier, value: RootViewData.summary) {
                SummaryView()
            }
            Tab(RootViewData.settings.title, systemImage: RootViewData.settings.iconIdentifier, value: RootViewData.settings) {
                Text(selection.title)
            }
        }
    }
}

#Preview {
    RootView()
}
