//
//  SwipeBack
//  OwlNav
//
//  Created by aaronevanjulio on 06/03/26.
//

import SwiftUI

/// A `ViewModifier` that enables the swipe-back gesture and coordinates pop completion callbacks.
public struct WithSwipeBackModifier: ViewModifier {
    /// Whether the swipe-back gesture is enabled.
    @Binding var isEnabled: Bool

    /// Callback triggered when a system swipe-back pop completes.
    var onPopCompleted: (() -> Void)?

    public func body(content: Content) -> some View {
        content
            .background(
                SwipeBackController(
                    isEnabled: $isEnabled,
                    onPopCompleted: onPopCompleted
                )
            )
    }
}

/// A background utility controller that enables the native swipe-back gesture based on stack state.
public struct SwipeBackController: UIViewControllerRepresentable {
    /// Whether the swipe-back gesture is enabled.
    @Binding var isEnabled: Bool

    /// Callback triggered when a system swipe-back pop completes.
    var onPopCompleted: (() -> Void)?

    public func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        controller.view.isHidden = true
        return controller
    }

    public func updateUIViewController(_ vc: UIViewController, context: Context) {
        // Walk up to the nearest UIHostingController to set associated-object flags.
        guard let hostingVC = vc.parent else { return }

        hostingVC.owlSwipeBackEnabled = isEnabled
        hostingVC.owlPopCompleted = onPopCompleted
    }
}
