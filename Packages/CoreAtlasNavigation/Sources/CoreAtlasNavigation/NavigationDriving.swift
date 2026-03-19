import Foundation

@MainActor
public protocol NavigationDriving {
    associatedtype Route: Hashable

    var path: [Route] { get set }

    mutating func push(_ route: Route)
    mutating func pop()
    mutating func popToRoot()
    mutating func replace(with path: [Route])
}
