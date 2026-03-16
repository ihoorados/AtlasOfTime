# Concurrency Guidelines

## Purpose

This document defines the concurrency model used in AtlasOfTime after the initial refactor work.

The goal is to keep async behavior:

- explicit
- reviewable
- testable
- stable under future feature growth

These rules are intentionally practical. They describe how concurrency is expected to work in this codebase today.

## Layer Rules

### Presentation

Presentation types that own UI-facing state must use explicit main-actor isolation.

Preferred pattern:

```swift
@MainActor
final class AtlasViewModel: ObservableObject {
    @Published var displayYear: Int = 0
    @Published var renderSnapshot: YearSnapshot?
}
```

Rules:

- Use `@MainActor` for SwiftUI-observed state owners.
- Do not use `@MainActor` to silence non-UI concurrency problems.
- Any unstructured task in Presentation must have an owner and a cancellation path.

### Domain

Domain should remain executor-agnostic and value-oriented where possible.

Preferred pattern:

```swift
struct YearSnapshot: Sendable {
    let year: Int
    let polygons: [GeoPolygon]
}
```

Rules:

- Prefer `Sendable` value types.
- Avoid actor or UI isolation in Domain unless the use case truly requires it.
- Domain contracts should not assume a UI executor.

### Data

Data uses actors for mutable coordination, not as a default container for all work.

Preferred pattern:

```swift
actor DefaultBorderRepository: BorderRepository {
    private var cachedYearIndex: YearIndex?
    private var inFlightSnapshots: [Int: Task<YearSnapshot, Error>] = [:]
}
```

Rules:

- Actors own shared mutable coordination state.
- Heavy loading, parsing, and decoding should be separated from actor coordination when possible.
- Repositories coordinate caching, in-flight deduplication, and policy.
- Loaders and decoders perform execution and transformation work.

## Approved Patterns

### 1. Explicit ViewModel task ownership

Preferred pattern:

```swift
@MainActor
final class AtlasViewModel: ObservableObject {
    private var bootstrapTask: Task<Void, Never>?
    private var loadTask: Task<Void, Never>?
}
```

Reason:

- startup work is owned
- active loads are owned
- teardown behavior is explicit

### 2. Debounce teardown is part of lifecycle

Preferred pattern:

```swift
deinit {
    bootstrapTask?.cancel()
    loadTask?.cancel()
    Task { [debouncer] in
        await debouncer.cancelAll()
    }
}
```

Reason:

- pending delayed work should not outlive the feature owner
- cancellation covers the full scheduling pipeline

### 3. Loader seam for expensive work

Preferred pattern:

```swift
protocol BorderSnapshotLoading: Sendable {
    func loadSnapshot(year: Int, relativePath: String) async throws -> YearSnapshot
}
```

Reason:

- repositories stay focused on coordination
- heavy work has a dedicated execution boundary
- tests can inject deterministic loaders

### 4. In-flight request deduplication

Preferred pattern:

```swift
if let inFlightTask = inFlightSnapshots[year] {
    return try await inFlightTask.value
}
```

Reason:

- cache handles completed work reuse
- in-flight map handles overlapping work deduplication

## Anti-Patterns

### 1. Using `@MainActor` as a generic fix

Avoid:

```swift
@MainActor
final class DefaultBorderRepository: BorderRepository { ... }
```

Why:

- repository is not UI state
- this moves data-layer responsibility onto the UI executor
- it hides architecture problems instead of fixing them

### 2. Fire-and-forget tasks without ownership

Avoid:

```swift
func onAppear() {
    Task {
        await bootstrap()
    }
}
```

unless ownership and cancellation are deliberately handled elsewhere.

Why:

- lifecycle becomes implicit
- stale work becomes harder to reason about

### 3. Actor as a dumping ground for heavy work

Avoid:

```swift
actor Repository {
    func load() async throws {
        let data = try readFile()
        let decoded = try decode(data)
        ...
    }
}
```

when the actor only needs to coordinate mutable state.

Why:

- serialization becomes broader than necessary
- throughput and clarity degrade

## Cache vs In-Flight Deduplication

These are not the same concern.

Cache:

```swift
if let cached = await cache.value(for: year) {
    return cached
}
```

In-flight deduplication:

```swift
if let inFlightTask = inFlightSnapshots[year] {
    return try await inFlightTask.value
}
```

Meaning:

- cache avoids repeating work after completion
- in-flight deduplication avoids repeating work while completion is still pending

## Build Settings Policy

Current direction:

- explicit type-level isolation is preferred over project-wide fallback behavior
- targeted strict concurrency is enabled
- the app target no longer relies on default `MainActor` isolation

This means future concurrency fixes should prefer:

- explicit `@MainActor` on UI state owners
- actor isolation for shared mutable coordination
- `Sendable` value modeling

instead of relying on target-wide defaults.
