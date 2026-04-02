import Foundation

public protocol YearIndexRepository: AnyObject, Sendable {
    func load() async throws -> YearIndex
}
