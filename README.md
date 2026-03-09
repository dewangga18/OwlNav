# OwlNav

`OwlNav` is a lightweight Swift Package for managing navigation state as a stack of routes.

It’s UI-framework agnostic: you can drive SwiftUI, UIKit, or your own navigation layer by observing and mutating a single source of truth (`stack`).

## Requirements

- Swift 5.9+
- iOS 15+ / macOS 12+

## Installation (Swift Package Manager)

Add `OwlNav` as a package dependency in Xcode (`File → Add Packages…`) or in your `Package.swift`.

## Core Type

- `OwlNavigator<Route>`: an `ObservableObject` that owns a `stack: [Route]` where `Route` is any `Hashable` type (commonly an enum).

## Usage

```swift
import OwlNav

enum Route: Hashable {
    case home
    case detail(id: Int)
}

@MainActor
let nav = OwlNavigator<Route>(stack: [.home])

nav.push(.detail(id: 42))
nav.pop()
nav.replaceTop(with: .home)
nav.popToRoot()
```

## Example

This repo includes a small executable example target located outside `Sources/`:

- Code: `Example/main.swift`
- Run: `swift run OwlNavExample`

