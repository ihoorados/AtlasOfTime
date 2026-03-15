# Step 2 - DI Rules and Target Design

## Objective
Define a minimal, typed DI container architecture per module/feature, without changing runtime behavior in this step.

## DI Rules
- Constructor injection only.
- No generic `resolve()` service locator.
- No global mutable singletons.
- Keep factories typed and explicit.
- Make lifetimes explicit.

## Target Containers

### App Container
- File: `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/DI/AppDIContainer.swift`
- Responsibility:
  - Composition root for module containers.
  - Creates and connects Data -> Domain -> Feature containers.

### Data Container
- File: `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/DI/DataDIContainer.swift`
- Responsibility:
  - Own app-scoped infrastructure.
  - Build repository implementations.
- App-scoped objects:
  - `BundleDataSource`
  - `LRUCache<Int, YearSnapshot>`
  - `DIYearIndexStore`
  - `DefaultYearIndexRepository`
  - `DefaultBorderRepository`

### Domain Container
- File: `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/DI/DomainDIContainer.swift`
- Responsibility:
  - Build use cases from repository abstractions.
  - Keep Domain independent from concrete Data types.

### Feature Container
- File: `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/Presentation/DI/AtlasFeatureDIContainer.swift`
- Responsibility:
  - Assemble `AtlasViewModel` (and feature screen factory method).
  - Keep feature assembly logic out of app entry.

## Lifetime Policy
- App-scoped:
  - Data/infrastructure and repositories.
- Feature-scoped:
  - Use cases and feature container assembly.
- View-scoped:
  - `AtlasViewModel` ownership remains in SwiftUI `@StateObject`.

## Notes
- This step introduces container structure only.
- Existing app wiring and behavior remain unchanged until Step 3 (composition root switch-over).
