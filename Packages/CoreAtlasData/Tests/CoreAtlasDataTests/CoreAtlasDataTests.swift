import Testing
import Foundation
import CoreAtlasDomain
@testable import CoreAtlasData

struct CoreAtlasDataTests {
    @Test func packageLoads() {
        #expect(CoreAtlasDataModule.self == CoreAtlasDataModule.self)
    }

    @Test
    func poiDecoderDecodesValidYearPayload() throws {
        let data = Data(validPOIJSON.utf8)

        let pois = try POIDecoder.decodePOIs(from: data, year: 1914)

        #expect(pois.count == 1)
        #expect(pois[0].id == "sarajevo-assassination-1914")
        #expect(pois[0].coordinate == Coordinate(lat: 43.8563, lon: 18.4131))
        #expect(pois[0].category == .politicalEvent)
        #expect(pois[0].confidence == .high)
    }

    @Test
    func poiDecoderRejectsMoreThanTenPOIsForOneYear() throws {
        let records = (1...11)
            .map { index in
                """
                {
                  "id": "poi-\(index)-1914",
                  "year": 1914,
                  "title": "POI \(index)",
                  "summary": "A curated event.",
                  "latitude": 10.0,
                  "longitude": 20.0,
                  "category": "other",
                  "confidence": "medium",
                  "relatedCountryIDs": [],
                  "sourceReferences": []
                }
                """
            }
            .joined(separator: ",")
        let data = Data("""
        {
          "year": 1914,
          "pointsOfInterest": [\(records)]
        }
        """.utf8)

        #expect(throws: AtlasDataError.self) {
            _ = try POIDecoder.decodePOIs(from: data, year: 1914)
        }
    }

    @Test
    func defaultPOIRepositoryReturnsEmptyListForMissingYearFile() async throws {
        let repository = DefaultPOIRepository(
            fileReader: TestPOIFileReader(files: [:])
        )

        let pois = try await repository.pointsOfInterest(for: 1815)

        #expect(pois.isEmpty)
    }

    @Test
    func defaultPOIRepositoryCachesLoadedYears() async throws {
        let reader = TestPOIFileReader(files: [
            "poi/1914.json": Data(validPOIJSON.utf8)
        ])
        let repository = DefaultPOIRepository(fileReader: reader)

        _ = try await repository.pointsOfInterest(for: 1914)
        _ = try await repository.pointsOfInterest(for: 1914)

        #expect(reader.readCount == 1)
    }
}

private let validPOIJSON = """
{
  "year": 1914,
  "pointsOfInterest": [
    {
      "id": "sarajevo-assassination-1914",
      "year": 1914,
      "title": "Assassination in Sarajevo",
      "summary": "A political assassination in Sarajevo triggered a wider diplomatic crisis in Europe.",
      "latitude": 43.8563,
      "longitude": 18.4131,
      "category": "politicalEvent",
      "confidence": "high",
      "relatedCountryIDs": [
        "austria-hungary",
        "serbia"
      ],
      "sourceReferences": [
        {
          "id": "example-source-sarajevo-1914",
          "title": "Example Historical Reference",
          "locator": "p. 12",
          "url": null,
          "note": "Used here only as a schema example."
        }
      ]
    }
  ]
}
"""

private final class TestPOIFileReader: POIFileReading, @unchecked Sendable {
    private let files: [String: Data]
    private let lock = NSLock()
    private var reads: Int = 0

    var readCount: Int {
        lock.withLock {
            reads
        }
    }

    init(files: [String: Data]) {
        self.files = files
    }

    func readPOIFile(relativePath: String) throws -> Data {
        guard let data = files[relativePath] else {
            throw AtlasDataError.resourceNotFound(relativePath)
        }
        lock.withLock {
            reads += 1
        }
        return data
    }
}
