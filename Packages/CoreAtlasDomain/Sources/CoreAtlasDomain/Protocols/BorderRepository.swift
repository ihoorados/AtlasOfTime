import Foundation

protocol BorderRepository: AnyObject, Sendable {
    func snapshot(for year: Int) async throws -> YearSnapshot
}
