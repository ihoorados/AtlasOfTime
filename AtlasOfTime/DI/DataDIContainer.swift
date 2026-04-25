import Foundation
import CoreAtlasData
import CoreAtlasDomain

// Data module container: owns app-scoped infrastructure and repository implementations.
final class DataDIContainer {
    private let dataSource: BundleDataSource
    private let borderCache: any CoreAtlasData.YearSnapshotCaching
    private let gzipDecoder: any CoreAtlasData.GzipDecoding
    private let borderDecoder: any CoreAtlasData.BorderDecoding
    private let borderSnapshotLoader: any CoreAtlasData.BorderSnapshotLoading

    private lazy var yearIndexRepository: any YearIndexRepository = {
        CoreAtlasData.DefaultYearIndexRepository(indexJSONReader: dataSource)
    }()

    private lazy var borderRepository: any BorderRepository = {
        return CoreAtlasData.DefaultBorderRepository(
            cache: borderCache,
            yearIndexRepository: yearIndexRepository,
            loader: borderSnapshotLoader
        )
    }()

    init(
        dataSource: BundleDataSource = BundleDataSource(),
        borderCache: any CoreAtlasData.YearSnapshotCaching = LRUCache<Int, YearSnapshot>(capacity: 4),
        gzipDecoder: any CoreAtlasData.GzipDecoding = CoreAtlasData.CompressionGzipDecoderAdapter(),
        borderDecoder: any CoreAtlasData.BorderDecoding = CoreAtlasData.GeoJSONBorderDecoderAdapter()
    ) {
        self.dataSource = dataSource
        self.borderCache = borderCache
        self.gzipDecoder = gzipDecoder
        self.borderDecoder = borderDecoder
        self.borderSnapshotLoader = CoreAtlasData.DefaultBorderSnapshotLoader(
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
