import MapKit
import ObjectiveC

enum BorderOverlayAdapter {
    private static let minimumCountryLabelArea = 0.05

    @MainActor
    static func makeOverlays(from snapshot: YearSnapshot?) -> [MKPolygon] {
        guard let snapshot else { return [] }
        return snapshot.snapshots
            .flatMap { countrySnapshot in
                countrySnapshot.extents.flatMap { extent in
                    extent.polygons.map { polygon in
                        makePolygonOverlay(from: polygon, snapshot: countrySnapshot)
                    }
                }
            }
    }

    static func makeCountryLabelPoints(from snapshot: YearSnapshot?) -> [CountryLabelPoint] {
        guard let snapshot else { return [] }

        return snapshot.snapshots.compactMap { countrySnapshot in
            let trimmedCountryName = countrySnapshot.displayName.trimmingCharacters(in: .whitespacesAndNewlines)
            let polygons = countrySnapshot.extents.flatMap(\.polygons)
            guard let polygon = largestPolygon(in: polygons),
                  !trimmedCountryName.isEmpty,
                  approximateArea(of: polygon) >= minimumCountryLabelArea,
                  let coordinate = representativeCoordinate(for: polygon) else {
                return nil
            }

            return CountryLabelPoint(
                countryID: countrySnapshot.id,
                countryName: trimmedCountryName,
                coordinate: coordinate
            )
        }
    }

    @MainActor
    private static func makePolygonOverlay(
        from polygon: GeoPolygon,
        snapshot: HistoricalCountrySnapshot
    ) -> MKPolygon {
        var outerCoordinates = polygon.outer.map {
            CLLocationCoordinate2D(latitude: $0.lat, longitude: $0.lon)
        }

        let holes: [MKPolygon] = polygon.holes.map { ring in
            var holeCoordinates = ring.map {
                CLLocationCoordinate2D(latitude: $0.lat, longitude: $0.lon)
            }
            return MKPolygon(coordinates: &holeCoordinates, count: holeCoordinates.count)
        }

        let overlay = MKPolygon(
            coordinates: &outerCoordinates,
            count: outerCoordinates.count,
            interiorPolygons: holes.isEmpty ? nil : holes
        )
        overlay.atlasCountryID = snapshot.id
        overlay.atlasCountryName = snapshot.displayName
        return overlay
    }

    private static func largestPolygon(in polygons: [GeoPolygon]) -> GeoPolygon? {
        polygons.max { approximateArea(of: $0) < approximateArea(of: $1) }
    }

    private static func representativeCoordinate(for polygon: GeoPolygon) -> CLLocationCoordinate2D? {
        guard !polygon.outer.isEmpty else { return nil }

        let centroid = centroid(of: polygon.outer)
        return CLLocationCoordinate2D(latitude: centroid.lat, longitude: centroid.lon)
    }

    private static func centroid(of ring: [Coordinate]) -> Coordinate {
        guard ring.count > 2 else {
            let averageLatitude = ring.map(\.lat).reduce(0, +) / Double(max(ring.count, 1))
            let averageLongitude = ring.map(\.lon).reduce(0, +) / Double(max(ring.count, 1))
            return Coordinate(lat: averageLatitude, lon: averageLongitude)
        }

        var signedArea = 0.0
        var centroidLatitude = 0.0
        var centroidLongitude = 0.0

        for index in ring.indices {
            let nextIndex = ring.index(after: index) == ring.endIndex ? ring.startIndex : ring.index(after: index)
            let current = ring[index]
            let next = ring[nextIndex]
            let cross = (current.lon * next.lat) - (next.lon * current.lat)

            signedArea += cross
            centroidLongitude += (current.lon + next.lon) * cross
            centroidLatitude += (current.lat + next.lat) * cross
        }

        guard signedArea != 0 else {
            let averageLatitude = ring.map(\.lat).reduce(0, +) / Double(ring.count)
            let averageLongitude = ring.map(\.lon).reduce(0, +) / Double(ring.count)
            return Coordinate(lat: averageLatitude, lon: averageLongitude)
        }

        let areaFactor = signedArea * 3
        return Coordinate(
            lat: centroidLatitude / areaFactor,
            lon: centroidLongitude / areaFactor
        )
    }

    private static func approximateArea(of polygon: GeoPolygon) -> Double {
        abs(signedArea(of: polygon.outer)) - polygon.holes.reduce(0) { partialResult, ring in
            partialResult + abs(signedArea(of: ring))
        }
    }

    private static func signedArea(of ring: [Coordinate]) -> Double {
        guard ring.count > 2 else { return 0 }

        var area = 0.0
        for index in ring.indices {
            let nextIndex = ring.index(after: index) == ring.endIndex ? ring.startIndex : ring.index(after: index)
            let current = ring[index]
            let next = ring[nextIndex]
            area += (current.lon * next.lat) - (next.lon * current.lat)
        }
        return area / 2
    }
}

struct CountryLabelPoint: Equatable, Sendable {
    let countryID: String
    let countryName: String
    let coordinate: CLLocationCoordinate2D

    static func == (lhs: CountryLabelPoint, rhs: CountryLabelPoint) -> Bool {
        lhs.countryID == rhs.countryID &&
        lhs.countryName == rhs.countryName &&
        lhs.coordinate.latitude == rhs.coordinate.latitude &&
        lhs.coordinate.longitude == rhs.coordinate.longitude
    }
}

@MainActor
private let atlasCountryIDAssociationKey = UnsafeRawPointer(UnsafeMutableRawPointer.allocate(byteCount: 1, alignment: 1))
@MainActor
private let atlasCountryNameAssociationKey = UnsafeRawPointer(UnsafeMutableRawPointer.allocate(byteCount: 1, alignment: 1))

@MainActor
extension MKPolygon {
    var atlasCountryID: String? {
        get { objc_getAssociatedObject(self, atlasCountryIDAssociationKey) as? String }
        set { objc_setAssociatedObject(self, atlasCountryIDAssociationKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC) }
    }

    var atlasCountryName: String? {
        get { objc_getAssociatedObject(self, atlasCountryNameAssociationKey) as? String }
        set { objc_setAssociatedObject(self, atlasCountryNameAssociationKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC) }
    }
}
