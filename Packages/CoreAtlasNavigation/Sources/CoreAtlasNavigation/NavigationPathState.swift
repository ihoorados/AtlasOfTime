import Foundation

@MainActor
public struct NavigationPathState<Route: Hashable>: NavigationDriving, Sendable {
    public var path: [Route]

    public init(path: [Route] = []) {
        self.path = path
    }

    public mutating func push(_ route: Route) {
        path.append(route)
    }

    public mutating func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    public mutating func popToRoot() {
        path.removeAll()
    }

    public mutating func replace(with path: [Route]) {
        self.path = path
    }
}
