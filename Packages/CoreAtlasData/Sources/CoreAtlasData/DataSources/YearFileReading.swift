import Foundation

public protocol YearFileReading: Sendable {
    func readYearFile(relativePath: String) throws -> Data
}
