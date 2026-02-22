import Foundation

protocol BorderRepository: Sendable {
    func snapshot(for year: Int) async throws -> YearSnapshot
}
