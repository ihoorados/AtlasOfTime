import CoreAtlasData
import CoreAtlasDomain
import Foundation
import Testing
@testable import AtlasOfTime

struct BundleDataSourceResourceTests {
    private struct IndexPayload: Decodable {
        let files: [String: String]
    }

    @Test
    func bundledIndexReferencesReadableYearFiles() async throws {
        let dataSource = BundleDataSource(bundle: .main)
        let repository = DefaultYearIndexRepository(indexJSONReader: dataSource)

        let index = try await repository.load()
        let payload = try JSONDecoder().decode(IndexPayload.self, from: dataSource.readIndexJSON())

        #expect(index.minYear == -123000)
        #expect(index.maxYear == 2010)
        #expect(!index.availableYears.isEmpty)

        for year in index.availableYears {
            let relativePath = try #require(
                payload.files[String(year)],
                "Index is missing a file path for available year \(year)."
            )
            let data = try dataSource.readYearFile(relativePath: relativePath)

            #expect(!data.isEmpty, "Bundled year file is empty for \(year): \(relativePath)")
        }
    }

    @Test(arguments: [1815, 1914, 1945])
    func bundledPOIPayloadsDecodeForCuratedYears(year: Int) async throws {
        let dataSource = BundleDataSource(bundle: .main)
        let repository = DefaultPOIRepository(fileReader: dataSource)

        let pointsOfInterest = try await repository.pointsOfInterest(for: year)

        #expect(!pointsOfInterest.isEmpty)
        #expect(pointsOfInterest.count <= 10)
        #expect(pointsOfInterest.allSatisfy { $0.year == year })
    }

    @Test
    func missingBundledPOIPayloadReturnsEmptyList() async throws {
        let dataSource = BundleDataSource(bundle: .main)
        let repository = DefaultPOIRepository(fileReader: dataSource)

        let pointsOfInterest = try await repository.pointsOfInterest(for: 1900)

        #expect(pointsOfInterest.isEmpty)
    }
}
