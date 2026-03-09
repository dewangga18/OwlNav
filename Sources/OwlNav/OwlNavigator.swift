import Combine
import Foundation

@MainActor
public final class OwlNavigator<Route: Hashable>: ObservableObject {
    @Published public private(set) var stack: [Route]

    public init(stack: [Route] = []) {
        self.stack = stack
    }

    public var top: Route? { stack.last }
    public var canPop: Bool { !stack.isEmpty }

    public func setStack(_ newStack: [Route]) {
        stack = newStack
    }

    public func push(_ route: Route) {
        stack.append(route)
    }

    @discardableResult
    public func pop() -> Route? {
        stack.popLast()
    }

    public func popToRoot() {
        stack.removeAll(keepingCapacity: true)
    }

    public func replaceTop(with route: Route) {
        if stack.isEmpty {
            stack = [route]
        } else {
            stack[stack.count - 1] = route
        }
    }
}

