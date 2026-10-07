//
//  StreamLegendView.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/6/26.
//

import SwiftUI

struct StreamLegendView : View {
    
    let viewData: [StreamLegendViewData]
    let onSelectionChanged: () -> Void
    
    var body: some View {
        CascadingGridLayout {
            ForEach(viewData, id: \.streamType) { data in
                ToggleableButton(
                    isSelected: data.isSelected,
                    label: Text(data.streamType.title).font(.caption)) {
                        Circle()
                            .fill(data.streamType.color)
                            .frame(width: .spacingMedium)
                    } onTap: {
                        withAnimation {
                            data.toggle()
                        }
                        onSelectionChanged()
                    }
            }
        }
    }
}

private struct ToggleableButton<LabelView: View>: View {
    
    let isSelected: Bool
    let label: Text
    let icon: () -> LabelView
    let onTap: () -> Void
    
    init(
        isSelected: Bool,
        label: Text,
        @ContentBuilder icon:  @escaping () -> LabelView,
        onTap: @escaping () -> Void
    ) {
        self.label = label
        self.icon = icon
        self.onTap = onTap
        self.isSelected = isSelected
    }
    
    var body: some View {
        Label {
            label.lineLimit(1)
        } icon: {
            icon()
        }
        .padding(.spacingSmall)
        .background {
            if isSelected {
                Color.gray.opacity(0.75)
            }
        }
        .clipShape(.capsule)
        .onTapGesture(perform: onTap)
    }
    
}

#Preview {
    let viewData = [
        StreamLegendViewData(
            streamType: .watts,
            isSelected: true
        ),
        StreamLegendViewData(
            streamType: .heartrate,
            isSelected: true
        ),
        StreamLegendViewData(
            streamType: .cadence,
            isSelected: false
        ),
    ]
    
    StreamLegendView(viewData: viewData, onSelectionChanged: {})
}
