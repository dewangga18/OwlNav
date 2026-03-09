import OwlNav
import SwiftUI

enum AppRoute: Equatable {
    case home
    case detail(id: Int)
}

struct HomeView: View {
    @ObservedObject var owl: InOwl<AppRoute>

    var body: some View {
        VStack(spacing: 12) {
            Text("Home")
                .font(.title)

            Button("Push detail") {
                owl.push(.detail(id: Int.random(in: 1...999)))
            }
        }
        .padding()
    }
}

struct DetailView: View {
    let id: Int
    @ObservedObject var owl: InOwl<AppRoute>

    var body: some View {
        VStack(spacing: 12) {
            Text("Detail \(id)")
                .font(.title)

            Button("Pop") {
                owl.pop()
            }

            Button("Reset to home") {
                owl.reset(.home)
            }
        }
        .padding()
    }
}

@main
struct OwlNavExampleApp: App {
    @StateObject private var owl = InOwl<AppRoute>(initial: .home)

    init() {
        OwlInject.initFunc()
    }

    var body: some Scene {
        WindowGroup {
            OwlContainer(owl) { route in
                switch route {
                case .home:
                    HomeView(owl: owl)
                case .detail(let id):
                    DetailView(id: id, owl: owl)
                }
            }
            .withSwipeBack(
                stackCount: Binding(
                    get: { owl.routes.count },
                    set: { _ in }
                )
            )
        }
    }
}

