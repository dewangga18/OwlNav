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
        backButtonAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.clear
        ]
        backButtonAppearance.highlighted.titleTextAttributes = [
            .foregroundColor: UIColor.clear
        ]

        let navAppearance = UINavigationBarAppearance()
        navAppearance.backButtonAppearance = backButtonAppearance
        navAppearance.setBackIndicatorImage(UIImage(), transitionMaskImage: UIImage())

        let appearance = UINavigationBar.appearance()
        appearance.standardAppearance = navAppearance
        appearance.compactAppearance = navAppearance
        appearance.tintColor = .clear
        appearance.isHidden = true

        if #available(iOS 15.0, *) {
            appearance.compactScrollEdgeAppearance = navAppearance
        }
    }
}
#endif

