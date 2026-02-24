# Step 4 - DI Contract Hardening

## Implemented
- Made `AtlasViewModel` debouncer dependency explicit (no default constructor in ViewModel init).
- Added decoder abstractions to remove static utility coupling in `BorderRepositoryImpl`:
  - `GzipDecoding`
  - `BorderDecoding`
- Added concrete adapters:
  - `CompressionGzipDecoderAdapter`
  - `GeoJSONBorderDecoderAdapter`
- Wired decoder abstractions through `DataDIContainer`.
- Wired explicit `Debouncer` and debounce config through `AtlasFeatureDIContainer`.

## Files
- `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/Presentation/AtlasViewModel.swift`
- `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/Data/Repositories/BorderRepositoryImpl.swift`
- `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/Data/Decoding/BorderDecoders.swift`
- `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/DI/DataDIContainer.swift`
- `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/Presentation/DI/AtlasFeatureDIContainer.swift`

## Outcome
- Dependencies are now explicit and container-owned where appropriate.
- Behavior remains unchanged.

