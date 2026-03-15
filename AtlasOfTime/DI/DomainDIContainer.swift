import Foundation

// Domain module container: creates use cases from repository abstractions.
struct DomainDIContainer {
    private let yearIndexRepository: any YearIndexRepository
    private let borderRepository: any BorderRepository

    init(
        yearIndexRepository: any YearIndexRepository,
        borderRepository: any BorderRepository
    ) {
        self.yearIndexRepository = yearIndexRepository
        self.borderRepository = borderRepository
    }

    func makeLoadYearIndex() -> LoadYearIndex {
        LoadYearIndex(repository: yearIndexRepository)
    }

    func makeLoadBordersForYear() -> LoadBordersForYear {
        LoadBordersForYear(repository: borderRepository)
    }
}

