import CoreAtlasDomain
import CoreAtlasData

extension LRUCache: CoreAtlasData.YearSnapshotCaching where Key == Int, Value == YearSnapshot {
    func snapshot(for year: Int) async -> YearSnapshot? {
        value(for: year)
    }

    func store(_ snapshot: YearSnapshot, for year: Int) async {
        setValue(snapshot, for: year)
    }
}
