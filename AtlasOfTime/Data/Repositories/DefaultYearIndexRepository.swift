import Foundation
import CoreAtlasDomain

actor DefaultYearIndexRepository: YearIndexRepository {
    private struct IndexDTO: Decodable {
        let minYear: Int
        let maxYear: Int
        let availableYears: [Int]
        let files: [String: String]
    }

    private let indexJSONReader: any IndexJSONReading
    private let decoder = JSONDecoder()

    init(indexJSONReader: any IndexJSONReading) {
        self.indexJSONReader = indexJSONReader
    }

    func load() async throws -> YearIndex {
        let rawData = try indexJSONReader.readIndexJSON()

        let dto: IndexDTO
        do {
            dto = try decoder.decode(IndexDTO.self, from: rawData)
        } catch {
            throw AtlasDataError.invalidIndexFormat(error.localizedDescription)
        }

        guard dto.minYear <= dto.maxYear else {
            throw AtlasDataError.invalidIndexFormat("minYear must be <= maxYear.")
        }

        var filesByYear: [Int: String] = [:]
        for (yearString, path) in dto.files {
            guard let year = Int(yearString) else { continue }
            filesByYear[year] = path
        }

        guard !filesByYear.isEmpty else {
            throw AtlasDataError.invalidIndexFormat("files dictionary is empty or keys are invalid.")
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
