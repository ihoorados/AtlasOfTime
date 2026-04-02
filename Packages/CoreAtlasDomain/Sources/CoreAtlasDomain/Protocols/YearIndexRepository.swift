import Foundation

protocol YearIndexRepository: AnyObject, Sendable {
    func load() async throws -> YearIndex
}
