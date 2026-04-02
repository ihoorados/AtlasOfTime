import Foundation
import CoreAtlasDomain

// Data module container: owns app-scoped infrastructure and repository implementations.
final class DataDIContainer {
    private let dataSource: BundleDataSource
    private let borderCache: LRUCache<Int, YearSnapshot>
    private let gzipDecoder: any GzipDecoding
    private let borderDecoder: any BorderDecoding
    private let borderSnapshotLoader: any BorderSnapshotLoading

    private lazy var yearIndexRepository: any YearIndexRepository = {
        DefaultYearIndexRepository(indexJSONReader: dataSource)
    }()

    private lazy var borderRepository: any BorderRepository = {
        return DefaultBorderRepository(
            cache: borderCache,
            yearIndexRepository: yearIndexRepository,
            loader: borderSnapshotLoader
        )
    }()

    init(
        dataSource: BundleDataSource = BundleDataSource(),
        borderCache: LRUCache<Int, YearSnapshot> = LRUCache<Int, YearSnapshot>(capacity: 4),
        gzipDecoder: any GzipDecoding = CompressionGzipDecoderAdapter(),
        borderDecoder: any BorderDecoding = GeoJSONBorderDecoderAdapter()
    ) {
        self.dataSource = dataSource
        self.borderCache = borderCache
        self.gzipDecoder = gzipDecoder
        self.borderDecoder = borderDecoder
        self.borderSnapshotLoader = DefaultBorderSnapshotLoader(
            yearFileReader: dataSource,
            gzipDecoder: gzipDecoder,
            borderDecoder: borderDecoder
        )
    }

    func makeYearIndexRepository() -> any YearIndexRepository {
        yearIndexRepository
    }

    func makeBorderRepository() -> any BorderRepository {
        borderRepository
    }
}
