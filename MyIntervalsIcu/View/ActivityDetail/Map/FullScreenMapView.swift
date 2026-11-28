//
//  FullScreenMapView.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 11/25/26.
//

import FactoryKit
import SwiftUI

struct FullScreenMapView: View {

    @State private var mapViewModel = Container.shared.mapViewModel.resolve()
    @Environment(NavigationViewModel.self) private var navigationViewModel: NavigationViewModel

    var body: some View {
        if let viewData = mapViewModel.viewData {
            ActivityMapView(viewData: viewData)
                .overlay(alignment: .topLeading) {
                    Button {
                        navigationViewModel.pop()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                    }
                    .buttonStyle(GlassButtonStyle())
                    .padding(.spacingMedium)
                }
        } else {
            ProgressView()
        }
    }
}
