import SwiftUI

@main
struct AtlasOfTimeApp: App {
    @StateObject private var viewModel: AtlasViewModel

    init() {
        let dataSource = BundleDataSource()
        let yearIndexRepository = YearIndexRepositoryImpl(dataSource: dataSource)

        let yearIndexStore = YearIndexStore()
        let borderCache = LRUCache<Int, YearSnapshot>(capacity: 4)

        let borderRepository = BorderRepositoryImpl(
            dataSource: dataSource,
            cache: borderCache,
            yearIndexProvider: {
                try await yearIndexStore.get()
            }
        )

        let loadYearIndex = LoadYearIndex(repository: yearIndexRepository)
        let loadBordersForYear = LoadBordersForYear(repository: borderRepository)

        _viewModel = StateObject(
            wrappedValue: AtlasViewModel(
                loadYearIndex: loadYearIndex,
                loadBordersForYear: loadBordersForYear,
                setYearIndex: { index in
                    await yearIndexStore.set(index)
                }
            )
        )
    }

    var body: some Scene {
        WindowGroup {
            AtlasScreen(viewModel: viewModel)
        }
    }
}

private actor YearIndexStore {
    private var index: YearIndex?

    func set(_ value: YearIndex) {
        index = value
    }

    func get() throws -> YearIndex {
        guard let index else {
            throw AppError.yearIndexNotLoaded
        }
        return index
    }
}
