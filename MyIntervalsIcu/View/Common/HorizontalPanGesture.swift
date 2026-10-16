//
//  HorizontalPanGesture.swift
//  MyIntervalsIcu
//
//  Created by Mike Rogers on 10/16/26.
//

import SwiftUI
import UIKit

struct HorizontalPanGesture<Content: View>: UIViewRepresentable {

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        private let onChanged: ((CGRect) -> Void)?
        private var startLocationX: CGFloat = .zero

        init(onChanged: ((CGRect) -> Void)?) {
            self.onChanged = onChanged
        }

        @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
            switch recognizer.state {
            case .began:
                startLocationX = recognizer.location(in: recognizer.view).x
                onChanged?(
                    CGRect(
                        x: startLocationX,
                        y: .zero,
                        width: .zero,
                        height: recognizer.view?.frame.height ?? .zero
                    )
                )
            case .changed:
                onChanged?(
                    CGRect(
                        x: startLocationX,
                        y: .zero,
                        width: recognizer.translation(in: recognizer.view).x,
                        height: recognizer.view?.frame.height ?? .zero
                    )
                )
            default:
                break
            }
        }

        func gestureRecognizerShouldBegin(
            _ gestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            guard let pan = gestureRecognizer as? UIPanGestureRecognizer else { return true }
            let velocity = pan.velocity(in: pan.view)
            return abs(velocity.x) > abs(velocity.y)
        }

        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            false
        }
    }

    let content: Content
    let onChanged: (CGRect) -> Void

    init(
        @ViewBuilder content: () -> Content,
        onChanged: @escaping (CGRect) -> Void
    ) {
        self.content = content()
        self.onChanged = onChanged
    }

    func makeUIView(context: Context) -> some UIView {
        let host = UIHostingController(rootView: content)
        host.view.backgroundColor = .clear

        let pan = UIPanGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handlePan(_:))
        )
        pan.delegate = context.coordinator
        host.view.addGestureRecognizer(pan)
        return host.view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        // Intentionally Blank
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onChanged: onChanged)
    }

}
