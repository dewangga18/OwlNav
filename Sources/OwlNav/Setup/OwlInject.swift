//
//  OwlInject
//  OwlNav
//
//  Created by aaronevanjulio on 06/03/26.
//

#if canImport(UIKit)
import UIKit

/// A utility struct to inject global navigation styles.
@MainActor public struct OwlInject {
    /// Configures the global appearance of the navigation bar to be transparent and hides the back button.
    public static func initFunc() {
        let backButtonAppearance = UIBarButtonItemAppearance()
        backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        backButtonAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.clear]
        backButtonAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: -1000, vertical: 0)

        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithTransparentBackground()
        navAppearance.backButtonAppearance = backButtonAppearance
        navAppearance.setBackIndicatorImage(UIImage(), transitionMaskImage: UIImage())
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor.clear]

        let appearance = UINavigationBar.appearance()
        appearance.standardAppearance = navAppearance
        appearance.compactAppearance = navAppearance
        appearance.tintColor = .clear

        if #available(iOS 15.0, *) {
            appearance.compactScrollEdgeAppearance = navAppearance
        }
    }
}
#endif

