import CoreAtlasDomain

protocol YearSnapshotCaching: Sendable {
    func snapshot(for year: Int) async -> YearSnapshot?
    func store(_ snapshot: YearSnapshot, for year: Int) async
}

extension LRUCache: YearSnapshotCaching where Key == Int, Value == YearSnapshot {
    func snapshot(for year: Int) async -> YearSnapshot? {
        await value(for: year)
    }

    func store(_ snapshot: YearSnapshot, for year: Int) async {
        await setValue(snapshot, for: year)
    }
}
