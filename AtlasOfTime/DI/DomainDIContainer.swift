import Foundation
import CoreAtlasDomain

// Domain module container: creates use cases from repository abstractions.
struct DomainDIContainer {
    private let yearIndexRepository: any YearIndexRepository
    private let borderRepository: any BorderRepository
    private let poiRepository: any POIRepository

    init(
        yearIndexRepository: any YearIndexRepository,
        borderRepository: any BorderRepository,
        poiRepository: any POIRepository
    ) {
        self.yearIndexRepository = yearIndexRepository
        self.borderRepository = borderRepository
        self.poiRepository = poiRepository
    }

    func makeLoadYearIndex() -> LoadYearIndex {
        LoadYearIndex(repository: yearIndexRepository)
    }

    func makeLoadBordersForYear() -> LoadBordersForYear {
        LoadBordersForYear(repository: borderRepository)
    }

    func makeLoadPOIsForYear() -> LoadPOIsForYear {
        LoadPOIsForYear(repository: poiRepository)
    }

    func makeGenerateCountrySummary(
        generator: any CountrySummaryGenerating
    ) -> GenerateCountrySummary {
        GenerateCountrySummary(generator: generator)
    }
}
