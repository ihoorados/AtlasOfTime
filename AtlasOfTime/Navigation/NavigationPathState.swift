import Foundation

@MainActor
struct NavigationPathState<Route: Hashable>: NavigationDriving, Equatable, Sendable {
    var path: [Route]

    init(path: [Route] = []) {
        self.path = path
    }

    mutating func push(_ route: Route) {
        path.append(route)
    }

    mutating func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    mutating func popToRoot() {
        path.removeAll()
    }

    mutating func replace(with path: [Route]) {
        self.path = path
    }
}
