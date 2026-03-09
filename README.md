# OwlNav

`OwlNav` is a lightweight Swift Package that bridges SwiftUI routing to a UIKit-backed `UINavigationController`.

## Requirements

- Swift 5.9+
- iOS 15+

## Installation (Swift Package Manager)

Add `OwlNav` as a package dependency in Xcode (`File → Add Packages…`) or in your `Package.swift`.

## Core Types

- `InOwl<Route>`: an `ObservableObject` holding `routes: [Route]` (your navigation stack).
- `OwlContainer`: a `UIViewControllerRepresentable` that keeps a `UINavigationController` in sync with `InOwl`.
- `OwlInject`: optional global navigation appearance config.
- `withSwipeBack(...)`: enables the native swipe-back gesture and keeps `InOwl` synchronized on interactive pops.

## Usage

```swift
import OwlNav
import SwiftUI

enum Route: Equatable {
    case home
    case detail(id: Int)
}

@MainActor
final class AppState: ObservableObject {
    let owl = InOwl<Route>(initial: .home)
}

struct RootView: View {
    @StateObject private var state = AppState()

    var body: some View {
        OwlContainer(state.owl) { route in
            Group {
                switch route {
                case .home:
                    VStack(spacing: 12) {
                        Text("Home")
                            .font(.title)

                        Button("Push detail") {
                            state.owl.push(.detail(id: 42))
                        }
                    }
                    .padding()
                case .detail(let id):
                    VStack(spacing: 12) {
                        Text("Detail \(id)")
                            .font(.title)

                        Button("Pop") {
                            state.owl.pop()
                        }
                    }
                    .padding()
                }
            }
            .navigationBarBackButtonHidden(true)
            .withSwipeBack(stackCount: Binding(get: { state.owl.routes.count }, set: { _ in })) {
                print("Route: \(state.owl.routes)")
            }
        }
    }
}
```

## Example

Example app code lives outside `Sources/` at `Example/OwlNavExampleApp.swift` (copy it into an iOS app target to try it).
