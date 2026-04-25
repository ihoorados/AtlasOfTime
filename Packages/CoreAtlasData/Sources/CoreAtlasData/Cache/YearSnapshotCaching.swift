import CoreAtlasDomain

public protocol YearSnapshotCaching: Sendable {
    func snapshot(for year: Int) async -> YearSnapshot?
    func store(_ snapshot: YearSnapshot, for year: Int) async
}
