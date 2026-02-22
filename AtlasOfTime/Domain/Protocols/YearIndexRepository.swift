import Foundation

protocol YearIndexRepository: Sendable {
    func load() async throws -> YearIndex
}
