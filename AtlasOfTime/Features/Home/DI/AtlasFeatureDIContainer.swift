import Foundation
import CoreAtlasDomain

// Atlas feature container: assembles feature-level presentation objects.
@MainActor
final class AtlasFeatureDIContainer {
    private let loadYearIndex: LoadYearIndex
    private let loadBordersForYear: LoadBordersForYear
    private let debounceNanoseconds: UInt64

    init(
        loadYearIndex: LoadYearIndex,
        loadBordersForYear: LoadBordersForYear,
        debounceNanoseconds: UInt64 = 150_000_000
    ) {
        self.loadYearIndex = loadYearIndex
        self.loadBordersForYear = loadBordersForYear
        self.debounceNanoseconds = debounceNanoseconds
    }

    func makeAtlasViewModel() -> AtlasViewModel {
        AtlasViewModel(
            loadYearIndex: loadYearIndex,
            loadBordersForYear: loadBordersForYear,
            debouncer: Debouncer(),
            debounceNanoseconds: debounceNanoseconds
        )
    }
}
