import Testing
@testable import CoreAtlasDomain

struct CoreAtlasDomainTests {
    @Test
    func packageLoads() {
        _ = CoreAtlasDomainModule.self
    }

    @Test
    func loadPOIsForYearDelegatesToRepository() async throws {
        let poi = HistoricalPOI(
            id: "sarajevo-1914",
            year: 1914,
            title: "Assassination in Sarajevo",
            summary: "A political assassination that escalated a wider crisis.",
            coordinate: Coordinate(lat: 43.8563, lon: 18.4131),
            category: .politicalEvent,
            confidence: .high,
            relatedCountryIDs: ["austria-hungary", "serbia"],
            sourceReferences: [
                HistoricalSourceReference(
                    id: "example-source",
                    title: "Example Source",
                    locator: "p. 12",
                    note: "Date and location"
                )
            ]
        )
        let repository = TestPOIRepository(result: .success([poi]))
        let useCase = LoadPOIsForYear(repository: repository)

        let loadedPOIs = try await useCase.execute(year: 1914)

        #expect(repository.requestedYears == [1914])
        #expect(loadedPOIs == [poi])
    }
}

private final class TestPOIRepository: POIRepository, @unchecked Sendable {
    var requestedYears: [Int] = []
    let result: Result<[HistoricalPOI], Error>

    init(result: Result<[HistoricalPOI], Error>) {
        self.result = result
    }

    func pointsOfInterest(for year: Int) async throws -> [HistoricalPOI] {
        requestedYears.append(year)
        return try result.get()
    }
}
