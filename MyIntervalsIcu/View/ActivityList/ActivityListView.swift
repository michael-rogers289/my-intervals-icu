//
//  ActivityListView.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 9/23/26.
//

import SwiftUI

struct ActivityListView : View {
    
    @State private var viewModel = ActivityListViewModel()
    
    var body: some View {
        NavigationStack {
            List(viewModel.activities) { activity in
                Text("ID: \(activity.id)")
            }.navigationTitle("Activities")
        }
        .onAppear { viewModel.startObservation() }
        
    }
    
}
