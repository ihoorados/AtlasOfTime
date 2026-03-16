# Step 1: Concurrency Baseline

## Purpose

This document establishes the current concurrency posture of AtlasOfTime before refactoring runtime behavior. The goal is to make isolation boundaries explicit and reviewable.

Step 1 does **not** change app behavior.

## Current Build Settings

From `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime.xcodeproj/project.pbxproj`:

```text
SWIFT_VERSION = 5.0
SWIFT_APPROACHABLE_CONCURRENCY = YES
SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor
```

## Current Isolation Model

### Presentation

Presentation state is intentionally main-actor isolated.

```swift
@MainActor
final class AtlasViewModel: ObservableObject {
    @Published var availableYears: [Int] = []
    @Published var displayYear: Int = 0
    @Published var renderSnapshot: YearSnapshot?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
}
```

Reason:
- SwiftUI-observed state must be mutated from the UI isolation boundary.
- View-driven loading and rendering coordination belong in Presentation.

### Domain

Domain types are value-oriented and `Sendable`.

```swift
struct YearSnapshot: Sendable {
    let year: Int
    let polygons: [GeoPolygon]
}

struct GeoPolygon: Equatable, Sendable {
    let outer: [Coordinate]
    let holes: [[Coordinate]]
}
```

Reason:
- Domain models should be portable across executors.
- Domain should not depend on UI or infrastructure isolation.

### Data

Shared mutable state is coordinated with actors.

```swift
actor DefaultBorderRepository: BorderRepository {
    private let cache: LRUCache<Int, YearSnapshot>
    private var cachedYearIndex: YearIndex?
}

actor LRUCache<Key: Hashable & Sendable, Value: Sendable> {
    private var nodesByKey: [Key: Node] = [:]
}
```

Reason:
- Repositories and caches coordinate mutable shared state.
- Actor isolation is appropriate for shared mutable coordination.

## Current Architectural Risk

The project-level default actor isolation is `MainActor`. That setting reduces compiler friction, but it can also blur layer boundaries by making non-UI code appear safer than it is.

The intended architecture is:

- `Presentation` is explicitly `@MainActor`
- `Domain` remains executor-agnostic and `Sendable`
- `Data` owns shared mutable state intentionally, without relying on UI isolation

This distinction matters because the app currently performs heavy loading and decoding work in the data layer:

```swift
func snapshot(for year: Int) async throws -> YearSnapshot {
    let compressedData = try dataSource.readYearFile(relativePath: relativePath)
    let geoJSONData = try gzipDecoder.gunzip(compressedData)
    let polygons = try borderDecoder.decodeBorders(from: geoJSONData)
    return YearSnapshot(year: year, polygons: polygons)
}
```

That code is safe from a race perspective, but it is not yet a clear concurrency design. The repository currently mixes:

- state coordination
- file IO
- decompression
- parsing

Later steps will separate those responsibilities.

## Layer Policy Going Forward

### Presentation

- Use `@MainActor` for view models and UI-facing state owners.
- Do not use `@MainActor` to silence non-UI concurrency problems.

### Domain

- Prefer value types.
- Keep domain models `Sendable`.
- Avoid executor assumptions.

### Data

- Use actors to protect mutable shared state.
- Avoid keeping heavy CPU and IO pipelines trapped inside actor-isolated methods when the actor only needs to coordinate state.

## Migration Policy

The project should move toward stricter concurrency incrementally.

Recommended sequence:

1. Make type-level isolation explicit.
2. Add tests for cancellation, ordering, and cache behavior.
3. Refactor actor bottlenecks in data loading.
4. Tighten build settings after isolation boundaries are defensible.

## Definition of Done for Step 1

Step 1 is complete when:

- the current concurrency model is documented
- the intended isolation policy by layer is explicit
- future refactor steps can be reviewed against this baseline
