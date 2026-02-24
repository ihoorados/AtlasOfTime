# Step 7 - Lifetime Policy and Validation

## Lifetime Policy
- App-scoped (single instance per app container):
  - `BundleDataSource`
  - `LRUCache<Int, YearSnapshot>`
  - `YearIndexRepositoryImpl`
  - `BorderRepositoryImpl`
  - Data decoder adapters
- Feature-scoped:
  - `AtlasFeatureDIContainer` assembly object
  - Use-case values built from repository abstractions
- View-scoped:
  - `AtlasViewModel` returned as a fresh instance per `makeAtlasViewModel()`

## Enforcement
- Repository protocols are class-bound (`AnyObject`) to make reference lifetime semantics explicit:
  - `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/Domain/Protocols/YearIndexRepository.swift`
  - `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/Domain/Protocols/BorderRepository.swift`

## Validation Tests
- Added DI lifetime tests:
  - `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTimeTests/DILifetimeTests.swift`
- Assertions:
  - Data container returns the same repository instances (app-scoped).
  - App container returns new `AtlasViewModel` instances (view-scoped).

## API Surface Cleanup
- Removed unused `makeAtlasScreen(viewModel:)` from:
  - `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/Presentation/DI/AtlasFeatureDIContainer.swift`

