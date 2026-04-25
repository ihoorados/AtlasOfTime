import Foundation

public struct YearIndex: Sendable {
    public let minYear: Int
    public let maxYear: Int
    public let availableYears: [Int]
    private let filesByYear: [Int: String]

    public init(minYear: Int, maxYear: Int, availableYears: [Int], filesByYear: [Int: String]) {
        self.minYear = minYear
        self.maxYear = maxYear
        self.availableYears = availableYears
        self.filesByYear = filesByYear
    }

    public func path(for year: Int) -> String? {
        filesByYear[year]
    }
}
