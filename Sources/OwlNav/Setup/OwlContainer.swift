//
//  OwlContainer
//  OwlNav
//
//  Created by aaronevanjulio on 06/03/26.
//

import SwiftUI

/// A bridge between SwiftUI and UIKit that provides a custom navigation container.
///
/// `OwlContainer` manages a `UINavigationController` and synchronizes its state with an `OwlNav` instance.
public struct OwlContainer<T: Equatable, Screen: View>: UIViewControllerRepresentable {
    /// The navigation manager that holds the route stack.
    @ObservedObject public var owl: InOwl<T>

    /// A closure that maps a route of type `T` to a SwiftUI `View`.
    @ViewBuilder private let routeMap: (T) -> Screen

    /// Initializes a new `OwlContainer`.
    /// - Parameters:
    ///   - owl: The `OwlNav` instance to observe.
    ///   - routeMap: A closure that provides the view for each route in the stack.
    public init(_ owl: InOwl<T>, @ViewBuilder routeMap: @escaping (T) -> Screen) {
        _owl = ObservedObject(wrappedValue: owl)
        self.routeMap = routeMap
    }

    /// Creates the underlying `UINavigationController`.
    public func makeUIViewController(context: Context) -> UINavigationController {
        let navigation = OwlNavigationController()

        navigation.onSystemPop = {
            owl.systemPop()
        }

        return navigation
    }

    /// Updates the `UINavigationController` to match the current state of the `OwlNav` stack.
    public func updateUIViewController(_ navigation: UINavigationController, context: Context) {
        syncNavigation(navigation)
    }

    private func syncNavigation(_ navigation: UINavigationController) {
        if let coordinator = navigation.transitionCoordinator {
            coordinator.animate(alongsideTransition: nil) { _ in
                syncNavigation(navigation)
            }
            return
        }

        let currentStack = navigation.viewControllers.count
        let targetStack = owl.routes.count

        if targetStack > currentStack {
            let shouldAnimate = currentStack > 0
            let newRoutes = owl.routes[currentStack..<targetStack]

            for (offset, route) in newRoutes.enumerated() {
                let isLast = offset == newRoutes.count - 1
                navigation.pushViewController(
                    UIHostingController(rootView: routeMap(route)),
                    animated: shouldAnimate && isLast
                )
            }
        }

        else if targetStack < currentStack {
            guard targetStack > 0 else { return }

            let targetVC = navigation.viewControllers[targetStack - 1]
            (navigation as? OwlNavigationController)?.suppressNextSystemPop()
            navigation.popToViewController(
                targetVC,
                animated: owl.consumePendingPopAnimated()
            )
        }

        else if targetStack == currentStack && targetStack > 0 {
            for index in 0..<targetStack {
                let hosting = navigation.viewControllers[index] as? UIHostingController<Screen>
                let route = owl.routes[index]

                hosting?.rootView = routeMap(route)
            }
        }
    }
}
