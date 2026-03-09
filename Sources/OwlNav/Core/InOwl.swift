//
//  InOwl
//  OwlNav
//
//  Created by aaronevanjulio on 09/03/26.
//

import SwiftUI

/// The navigation manager responsible for maintaining the route stack.
///
/// `OwlNav` is a `@MainActor` observed object that tracks an array of routes and provides methods to manipulate the stack.
@MainActor public class InOwl<T: Equatable>: ObservableObject {
    /// The current navigation stack.
    @Published public private(set) var routes: [T] = []
    
    /// Animation flag for the next pop operation.
    private var pendingPopAnimated: Bool = true

    /// Initializes a new `OwlNav` with an initial route.
    /// - Parameter initial: The starting route of the navigation stack.
    public init(initial: T) {
        routes = [initial]
    }

    /// Pushes a new route onto the stack.
    /// - Parameter route: The new route to push.
    public func push(_ route: T) {
        routes.append(route)
    }

    /// Pops the top route from the stack.
    /// - Parameter animated: Whether the pop should be animated.
    public func pop(animated: Bool = true) {
        guard routes.count > 1 else { return }
        pendingPopAnimated = animated
        routes.removeLast()
    }

    /// Replaces the current top route with a new one.
    /// - Parameter route: The route to replace the current top with.
    public func replace(_ route: T) {
        guard routes.count > 0 else {
            routes = [route]
            return
        }

        routes[routes.count - 1] = route
    }

    /// Pops to a specific route in the stack.
    /// - Parameters:
    ///   - route: The target route to pop to.
    ///   - inclusive: If `true`, the target route itself will also be popped.
    ///   - animated: Whether the pop should be animated.
    public func popTo(_ route: T, inclusive: Bool = false, animated: Bool = true) {
        guard !routes.isEmpty else { return }

        guard var foundIndex = routes.lastIndex(where: { $0 == route }) else { return }

        if !inclusive {
            foundIndex += 1
        }

        foundIndex = max(foundIndex, 1)

        let numToPop = (foundIndex..<routes.endIndex).count
        guard numToPop > 0 else { return }

        pendingPopAnimated = animated
        routes.removeLast(numToPop)
    }

    /// Resets the stack to a single route.
    /// - Parameter route: The new root route.
    public func reset(_ route: T) {
        pendingPopAnimated = false
        routes = [route]
    }

    /// Internal method to handle system-initiated pop events (e.g., swipe back).
    func systemPop() {
        guard routes.count > 1 else { return }
        routes.removeLast()
    }

    /// Consumes and returns the pending animation flag for a pop operation.
    /// This resets the flag to `true` after being called.
    func consumePendingPopAnimated() -> Bool {
        let animated = pendingPopAnimated
        pendingPopAnimated = true
        return animated
    }
}
