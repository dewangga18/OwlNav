//
//  OwlInject
//  OwlNav
//
//  Created by aaronevanjulio on 06/03/26.
//

#if canImport(UIKit)
import UIKit

public enum OwlNavBarBehavior {
    case alwaysHidden
    case transparentWhenAtTop
}

/// A utility struct to inject global navigation styles.
@MainActor public struct OwlInject {
    /// Configures the global appearance of the navigation bar to be transparent and hides the back button.
    public static func initFunc(navBarBehavior: OwlNavBarBehavior = .alwaysHidden) {
        let backButtonAppearance = UIBarButtonItemAppearance()
        backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        backButtonAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.clear]

        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithTransparentBackground()
        navAppearance.backButtonAppearance = backButtonAppearance
        navAppearance.setBackIndicatorImage(UIImage(), transitionMaskImage: UIImage())

        let appearance = UINavigationBar.appearance()
        appearance.standardAppearance = navAppearance
        appearance.compactAppearance = navAppearance
        appearance.tintColor = .clear
        appearance.isHidden = true

        switch navBarBehavior {
        case .alwaysHidden:
            appearance.scrollEdgeAppearance = navAppearance
            if #available(iOS 15.0, *) {
                appearance.compactScrollEdgeAppearance = navAppearance
            }
        case .transparentWhenAtTop:
            let transparentAppearance = UINavigationBarAppearance()
            transparentAppearance.configureWithTransparentBackground()
            transparentAppearance.backButtonAppearance = backButtonAppearance
            transparentAppearance.setBackIndicatorImage(UIImage(), transitionMaskImage: UIImage())
            appearance.scrollEdgeAppearance = transparentAppearance
            if #available(iOS 15.0, *) {
                appearance.compactScrollEdgeAppearance = transparentAppearance
            }
        }
    }
}
#endif

