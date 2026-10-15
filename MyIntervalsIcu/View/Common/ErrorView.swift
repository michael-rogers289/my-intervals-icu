//
//  ErrorView.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/14/26.
//

import SwiftUI

struct ErrorViewData {
    let errorText: String
    let error: any Error?
}

struct ErrorView: View {
    
    @Binding var isPresented: Bool
    let viewData: ErrorViewData
    @State private var showDetailedError = false
    
    var body: some View {
        VStack(spacing: .spacingMedium) {
            Text(viewData.errorText)
                .font(.headline)
            if showDetailedError,
               let error = viewData.error {
                Text(error.localizedDescription)
                    .font(.caption)
                    .transition(
                        .scale
                            .combined(with: .opacity)
                            .animation(.easeInOut)
                    )
            }
        }
            .fontWeight(.semibold)
            .padding(.spacingLarge)
            .background {
                Capsule()
                    .glassEffect(.clear.interactive())
            }
            .onTapGesture {
                guard viewData.error != nil else { return }
                withAnimation {
                    showDetailedError.toggle()
                }
            }
            .swipeActions {
                Button(role: .destructive) {
                    withAnimation {
                        isPresented = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                }
            }
            .transition(
                unsafe .asymmetric(
                    insertion: .move(edge: .bottom)
                        .animation(.easeIn)
                        .combined(with: .opacity),
                    removal: .move(edge: .leading)
                        .animation(.easeOut)
                        .combined(with: .opacity)
                )
                
            )
    }
    
}

#Preview {
    ErrorView(
        isPresented: Binding(get: { true }, set: { _ in }),
        viewData: ErrorViewData(
            errorText: "Something went wrong. Please Try again.",
            error: nil
        )
    )
    ErrorView(
        isPresented: Binding(get: { true }, set: { _ in }),
        viewData: ErrorViewData(
            errorText: "Something went wrong. Please Try again.",
            error: NetworkManager.NetworkError.unableToFetchData(forPath: "/activities")
        )
    )
}
