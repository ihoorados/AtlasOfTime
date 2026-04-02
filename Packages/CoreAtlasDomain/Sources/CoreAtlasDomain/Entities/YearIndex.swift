import Foundation

struct YearIndex: Sendable {
    let minYear: Int
    let maxYear: Int
    let availableYears: [Int]
    private let filesByYear: [Int: String]

    init(minYear: Int, maxYear: Int, availableYears: [Int], filesByYear: [Int: String]) {
        self.minYear = minYear
        self.maxYear = maxYear
        self.availableYears = availableYears
        self.filesByYear = filesByYear
    }

    func path(for year: Int) -> String? {
        filesByYear[year]
    }
}
