//
//  Views+Extensions
//  OwlNav
//
//  Created by aaronevanjulio on 06/03/26.
//

import SwiftUI

extension View {
    /// Configures the navigation bar to be transparent if available.
    /// - Parameter removeBackground: If `true`, hides the toolbar background and sets it to clear on iOS 16+.
    /// - Returns: A view with a transparent or default navigation bar.
    @ViewBuilder public func transparentNavigationBarIfAvailable(removeBackground: Bool = true) -> some View {
        if #available(iOS 16.0, *) {
            if removeBackground {
                self
                    .toolbar(.visible, for: .navigationBar)
                    .toolbarBackground(.hidden, for: .navigationBar)
                    .toolbarBackground(.clear, for: .navigationBar)
            } else {
                self
                    .toolbar(.visible, for: .navigationBar)
            }
        } else {
            self
                .navigationBarHidden(false)
        }
    }

    /// Hides the navigation bar if available.
    /// - Returns: A view with a hidden navigation bar.
    @ViewBuilder public func hideNavigationBarIfAvailable() -> some View {
        if #available(iOS 16.0, *) {
            self
                .toolbar(.hidden, for: .navigationBar)
        } else {
            self
                .navigationBarHidden(true)
        }
    }

    /// Enables the custom swipe-back gesture for the view.
    /// - Parameters:
    ///   - stackCount: A binding to the current navigation stack count.
    ///   - onPopCompleted: An optional callback triggered when a pop operation completes.
    /// - Returns: A view with swipe-back functionality enabled.
    public func withSwipeBack(stackCount: Binding<Int>, onPopCompleted: (() -> Void)? = nil) -> some View {
        modifier(WithSwipeBackModifier(stackCount: stackCount, onPopCompleted: onPopCompleted))
    }
}
