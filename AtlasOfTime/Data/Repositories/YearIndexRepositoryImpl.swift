import Foundation

actor YearIndexRepositoryImpl: YearIndexRepository {
    private struct IndexDTO: Decodable {
        let minYear: Int
        let maxYear: Int
        let availableYears: [Int]
        let files: [String: String]
    }

    private let dataSource: BundleDataSource
    private let decoder = JSONDecoder()

    init(dataSource: BundleDataSource) {
        self.dataSource = dataSource
    }

    func load() async throws -> YearIndex {
        let rawData = try dataSource.readIndexJSON()

        let dto: IndexDTO
        do {
            dto = try decoder.decode(IndexDTO.self, from: rawData)
        } catch {
            throw AppError.invalidIndexFormat(error.localizedDescription)
        }

        guard dto.minYear <= dto.maxYear else {
            throw AppError.invalidIndexFormat("minYear must be <= maxYear.")
        }

        var filesByYear: [Int: String] = [:]
        for (yearString, path) in dto.files {
            guard let year = Int(yearString) else { continue }
            filesByYear[year] = path
        }

        guard !filesByYear.isEmpty else {
            throw AppError.invalidIndexFormat("files dictionary is empty or keys are invalid.")
        }

        let years = dto.availableYears.isEmpty
            ? Array(dto.minYear...dto.maxYear)
            : dto.availableYears.sorted()

        return YearIndex(
            minYear: dto.minYear,
            maxYear: dto.maxYear,
            availableYears: years,
            filesByYear: filesByYear
        )
    }
}
