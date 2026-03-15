# Step 1 - Dependency Audit (Current State)

## Scope
- App: `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/Presentation/AtlasOfTimeApp.swift`
- Presentation: `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/Presentation/AtlasViewModel.swift`
- Domain: `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/Domain`
- Data: `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/Data`

## Current Composition Root
- Composition root is `AtlasOfTimeApp.init()`.
- Concrete dependency creation currently happens directly in app entry:
  - `BundleDataSource`
  - `DefaultYearIndexRepository`
  - `LRUCache<Int, YearSnapshot>`
  - `DefaultBorderRepository`
  - `LoadYearIndex`
  - `LoadBordersForYear`
  - `AtlasViewModel`

## Dependency Graph (Current)
1. `AtlasOfTimeApp` creates `BundleDataSource`.
2. `AtlasOfTimeApp` creates `DefaultYearIndexRepository(dataSource:)`.
3. `AtlasOfTimeApp` creates `YearIndexStore` actor.
4. `AtlasOfTimeApp` creates `LRUCache<Int, YearSnapshot>(capacity: 4)`.
5. `AtlasOfTimeApp` creates `DefaultBorderRepository(dataSource:cache:yearIndexProvider:)`.
6. `AtlasOfTimeApp` creates use cases from repository protocols:
   - `LoadYearIndex(repository:)`
   - `LoadBordersForYear(repository:)`
7. `AtlasOfTimeApp` creates `AtlasViewModel(loadYearIndex:loadBordersForYear:setYearIndex:)`.
8. `AtlasScreen` consumes the injected `AtlasViewModel`.

## Lifecycle Classification
- App-scoped:
  - `BundleDataSource`
  - `DefaultYearIndexRepository`
  - `DefaultBorderRepository`
  - `LRUCache`
  - `YearIndexStore`
  - Use cases
- View-scoped:
  - `AtlasViewModel` as `@StateObject`
- Internal utility-scoped:
  - `Debouncer` defaulted inside `AtlasViewModel` initializer

## Clean Architecture Status
- Good:
  - Domain depends on repository protocols (`YearIndexRepository`, `BorderRepository`).
  - Data implements domain protocols.
  - MapKit is contained in Presentation layer.
- Refactor targets:
  - App composition logic is monolithic in `AtlasOfTimeApp`.
  - `YearIndexStore` closure bridging (`setYearIndex`, `yearIndexProvider`) is orchestration logic embedded in root.
  - `DefaultBorderRepository` hard-codes decoder implementations (`GzipDecoder`, `GeoJSONBorderDecoder`) instead of injectable collaborators.
  - `AtlasViewModel` provides default `Debouncer()`, reducing strict DI consistency.

## Step 1 Output
- Baseline dependency graph and lifecycle map documented.
- No behavior or runtime wiring changes introduced in this step.
