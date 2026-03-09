//
//  SwipeBack
//  OwlNav
//
//  Created by aaronevanjulio on 06/03/26.
//

import SwiftUI

/// A `ViewModifier` that enables the swipe-back gesture and coordinates pop completion callbacks.
public struct WithSwipeBackModifier: ViewModifier {
    /// Binding to the current stack count.
    @Binding var stackCount: Int
    
    /// Callback triggered when a pop operation completes.
    var onPopCompleted: (() -> Void)?

    public func body(content: Content) -> some View {
        content
            .background(
                SwipeBackController(
                    stackCount: $stackCount,
                    onPopCompleted: onPopCompleted
                )
            )
    }
}

/// A background utility controller that enables the native swipe-back gesture based on stack state.
public struct SwipeBackController: UIViewControllerRepresentable {
    /// Binding to the current stack count.
    @Binding var stackCount: Int
    /// Callback triggered when a pop operation completes.
    var onPopCompleted: (() -> Void)?

    public func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        controller.view.isHidden = true
        return controller
    }

    public func updateUIViewController(_ vc: UIViewController, context: Context) {
        guard let nav = vc.navigationController else { return }

        nav.interactivePopGestureRecognizer?.isEnabled = stackCount > 1

        if let safeNav = nav as? OwlNavigationController {
            safeNav.onSystemPopCompleted = onPopCompleted
        }
    }
}
