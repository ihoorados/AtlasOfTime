import Foundation
import CoreAtlasDomain

// Atlas feature container: assembles feature-level presentation objects.
@MainActor
final class AtlasFeatureDIContainer {
    private let loadYearIndex: LoadYearIndex
    private let loadBordersForYear: LoadBordersForYear
    private let loadPOIsForYear: LoadPOIsForYear
    private let debounceNanoseconds: UInt64

    init(
        loadYearIndex: LoadYearIndex,
        loadBordersForYear: LoadBordersForYear,
        loadPOIsForYear: LoadPOIsForYear,
        debounceNanoseconds: UInt64 = 150_000_000
    ) {
        self.loadYearIndex = loadYearIndex
        self.loadBordersForYear = loadBordersForYear
        self.loadPOIsForYear = loadPOIsForYear
        self.debounceNanoseconds = debounceNanoseconds
    }

    func makeAtlasViewModel() -> AtlasViewModel {
        AtlasViewModel(
            loadYearIndex: loadYearIndex,
            loadBordersForYear: loadBordersForYear,
            loadPOIsForYear: loadPOIsForYear,
            debouncer: Debouncer(),
            debounceNanoseconds: debounceNanoseconds
        )
    }
}
