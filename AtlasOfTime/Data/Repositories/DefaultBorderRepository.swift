import Foundation

actor DefaultBorderRepository: BorderRepository {
    private let cache: LRUCache<Int, YearSnapshot>
    private let yearIndexRepository: any YearIndexRepository
    private let loader: any BorderSnapshotLoading
    private var cachedYearIndex: YearIndex?

    init(
        cache: LRUCache<Int, YearSnapshot>,
        yearIndexRepository: any YearIndexRepository,
        loader: any BorderSnapshotLoading
    ) {
        self.cache = cache
        self.yearIndexRepository = yearIndexRepository
        self.loader = loader
    }

    func snapshot(for year: Int) async throws -> YearSnapshot {
        if let cached = await cache.value(for: year) {
            return cached
        }

        let index = try await currentYearIndex()
        guard let relativePath = index.path(for: year) else {
            throw AppError.yearUnavailable(year)
        }

        let snapshot = try await loader.loadSnapshot(year: year, relativePath: relativePath)
        await cache.setValue(snapshot, for: year)
        return snapshot
    }

    private func currentYearIndex() async throws -> YearIndex {
        if let cachedYearIndex {
            return cachedYearIndex
        }

        let loaded = try await yearIndexRepository.load()
        cachedYearIndex = loaded
        return loaded
    }
}
