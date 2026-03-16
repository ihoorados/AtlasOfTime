import Foundation

actor DefaultBorderRepository: BorderRepository {
    private let cache: LRUCache<Int, YearSnapshot>
    private let yearIndexRepository: any YearIndexRepository
    private let loader: any BorderSnapshotLoading
    private var cachedYearIndex: YearIndex?
    private var inFlightSnapshots: [Int: Task<YearSnapshot, Error>] = [:]

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

        if let inFlightTask = inFlightSnapshots[year] {
            return try await inFlightTask.value
        }

        let index = try await currentYearIndex()
        guard let relativePath = index.path(for: year) else {
            throw AppError.yearUnavailable(year)
        }

        let task = Task<YearSnapshot, Error> { [loader] in
            try await loader.loadSnapshot(year: year, relativePath: relativePath)
        }
        inFlightSnapshots[year] = task
        defer { inFlightSnapshots[year] = nil }

        let snapshot = try await task.value
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
