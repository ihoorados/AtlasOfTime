import Foundation

// Data module container: owns app-scoped infrastructure and repository implementations.
final class DataDIContainer {
    private let dataSource: BundleDataSource
    private let borderCache: LRUCache<Int, YearSnapshot>
    private let gzipDecoder: any GzipDecoding
    private let borderDecoder: any BorderDecoding

    private lazy var yearIndexRepository: any YearIndexRepository = {
        YearIndexRepositoryImpl(dataSource: dataSource)
    }()

    private lazy var borderRepository: any BorderRepository = {
        return BorderRepositoryImpl(
            dataSource: dataSource,
            cache: borderCache,
            yearIndexRepository: yearIndexRepository,
            gzipDecoder: gzipDecoder,
            borderDecoder: borderDecoder
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
    }

    func makeYearIndexRepository() -> any YearIndexRepository {
        yearIndexRepository
    }

    func makeBorderRepository() -> any BorderRepository {
        borderRepository
    }
}
