import Foundation

protocol YearFileReading: Sendable {
    func readYearFile(relativePath: String) throws -> Data
}
