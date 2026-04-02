import Foundation
import CoreAtlasDomain

public actor DefaultBorderRepository: BorderRepository {
    private let cache: any YearSnapshotCaching
    private let yearIndexRepository: any YearIndexRepository
    private let loader: any BorderSnapshotLoading
    private var cachedYearIndex: YearIndex?
    private var inFlightSnapshots: [Int: Task<YearSnapshot, Error>] = [:]

    public init(
        cache: any YearSnapshotCaching,
        yearIndexRepository: any YearIndexRepository,
        loader: any BorderSnapshotLoading
    ) {
        self.cache = cache
        self.yearIndexRepository = yearIndexRepository
        self.loader = loader
    }

    public func snapshot(for year: Int) async throws -> YearSnapshot {
        if let cached = await cache.snapshot(for: year) {
            return cached
        }

        if let inFlightTask = inFlightSnapshots[year] {
            return try await inFlightTask.value
        }

        let index = try await currentYearIndex()
        guard let relativePath = index.path(for: year) else {
            throw AtlasDomainError.yearUnavailable(year)
        }

        let task = Task<YearSnapshot, Error> { [loader] in
            try await loader.loadSnapshot(year: year, relativePath: relativePath)
        }
        inFlightSnapshots[year] = task
        defer { inFlightSnapshots[year] = nil }

        let snapshot = try await task.value
        try Task.checkCancellation()
        await cache.store(snapshot, for: year)
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
