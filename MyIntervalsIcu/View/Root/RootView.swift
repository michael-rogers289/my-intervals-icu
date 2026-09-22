//
//  RootView.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 8/30/26.
//

import SwiftUI

struct RootView: View {
    
    @State private var selection: RootViewData?
    
    var body: some View {
        NavigationSplitView(
            sidebar: {
                List(RootViewData.allCases, id: \.self, selection: $selection) { rootViewData in
                    Label(
                        title: {
                            Text(rootViewData.title)
                        },
                        icon: {
                            Image(systemName: rootViewData.iconIdentifier)
                        }
                    )
                }
            }, detail: {
                switch selection {
                case .home, .settings: Text(selection?.title ?? "")
                case .summary:
                    SummaryView()
                default: Text("No Selection")
                }
            }
        )
    }
}

#Preview {
    RootView()
}
