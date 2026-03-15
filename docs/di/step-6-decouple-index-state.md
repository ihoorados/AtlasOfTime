# Step 6 - Remove Cross-UseCase Index State Coupling

## Implemented
- Removed Presentation -> Data callback coupling (`setYearIndex`).
- Refactored border repository to own lazy year-index loading through `YearIndexRepository`.
- Removed `DIYearIndexStore` and related setter wiring from Data container.
- Updated app/feature/preview/test DI assembly to new signatures.

## Files Updated
- `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/Data/Repositories/DefaultBorderRepository.swift`
- `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/DI/DataDIContainer.swift`
- `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/Presentation/AtlasViewModel.swift`
- `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/Presentation/DI/AtlasFeatureDIContainer.swift`
- `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/DI/AppDIContainer.swift`
- `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/DI/PreviewAppDIContainer.swift`
- `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTimeTests/AtlasViewModelDITests.swift`

## Outcome
- Cleaner dependency direction.
- Lower orchestration leakage from Presentation into Data internals.
- Runtime behavior preserved.
