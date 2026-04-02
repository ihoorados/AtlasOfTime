import Foundation

public protocol YearIndexRepository: Sendable {
    func load() async throws -> YearIndex
}
