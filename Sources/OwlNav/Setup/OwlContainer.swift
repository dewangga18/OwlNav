//
//  OwlContainer
//  OwlNav
//
//  Created by aaronevanjulio on 06/03/26.
//

import SwiftUI

/// A lightweight `UIHostingController` subclass that stores its route value directly,
/// avoiding the need to access `.view.tag` (which force-loads the view hierarchy).
final class OwlHostingController<T: Equatable, Screen: View>: UIHostingController<Screen> {
    /// The route this controller represents.
    let route: T

    init(route: T, rootView: Screen) {
        self.route = route
        super.init(rootView: rootView)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

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
        // Prevent duplicate sync calls when a transition is in flight.
        if let owlNav = navigation as? OwlNavigationController, owlNav.isSyncScheduled {
            return
        }

        if let coordinator = navigation.transitionCoordinator {
            (navigation as? OwlNavigationController)?.isSyncScheduled = true
            coordinator.animate(alongsideTransition: nil) { _ in
                (navigation as? OwlNavigationController)?.isSyncScheduled = false
                syncNavigation(navigation)
            }
            return
        }

        let currentStack = navigation.viewControllers.count
        let targetStack = owl.routes.count

        if targetStack > currentStack {
            // Atomic multi-push: build the full target stack and set it in one shot.
            var newStack = navigation.viewControllers
            let newRoutes = owl.routes[currentStack..<targetStack]

            for route in newRoutes {
                let hosting = OwlHostingController(route: route, rootView: routeMap(route))
                newStack.append(hosting)
            }

            let shouldAnimate = currentStack > 0
            navigation.setViewControllers(newStack, animated: shouldAnimate)
        }

        else if targetStack < currentStack {
            guard targetStack > 0 else { return }

            // Build the target stack in one shot:
            // reuse existing VCs where the route is unchanged, recreate where it differs (e.g. reset to a new root).
            var newStack: [UIViewController] = []
            for index in 0..<targetStack {
                let route = owl.routes[index]
                let existing = navigation.viewControllers[index] as? OwlHostingController<T, Screen>

                if let existing, existing.route == route {
                    newStack.append(existing)
                } else {
                    let newHosting = OwlHostingController(route: route, rootView: routeMap(route))
                    newStack.append(newHosting)
                }
            }

            (navigation as? OwlNavigationController)?.suppressNextSystemPop()
            navigation.setViewControllers(newStack, animated: owl.consumePendingPopAnimated())
        }

        else if targetStack == currentStack && targetStack > 0 {
            var newStack = navigation.viewControllers
            var didChange = false

            for index in 0..<targetStack {
                let route = owl.routes[index]
                let existing = navigation.viewControllers[index] as? OwlHostingController<T, Screen>

                if existing?.route != route {
                    let newHosting = OwlHostingController(route: route, rootView: routeMap(route))
                    newStack[index] = newHosting
                    didChange = true
                }
            }

            if didChange {
                navigation.setViewControllers(newStack, animated: false)
            }
        }
    }
}
