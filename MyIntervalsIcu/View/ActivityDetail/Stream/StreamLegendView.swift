//
//  StreamLegendView.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/6/26.
//

import SwiftUI

struct StreamLegendView : View {
    
    @Binding var viewData: [StreamLegendViewData]
    
    var body: some View {
        CascadingGridLayout {
            ForEach(0..<viewData.count, id: \.self) { index in
                let data = viewData[index]
                ToggleableButton(
                    isSelected: data.isSelected,
                    label: Text(data.streamType.title).font(.caption)) {
                        Circle()
                            .fill(data.streamType.color)
                            .frame(width: .spacingMedium)
                    } onTap: {
                        withAnimation {
                            viewData[index].toggle()
                        }
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
    let viewDataBinding = Binding(get: {
        [
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
    }, set: { _ in
        
    })
    
    
    StreamLegendView(viewData: viewDataBinding)
}
