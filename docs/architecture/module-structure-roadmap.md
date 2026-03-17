# Module Structure Roadmap

## Current Layout

```text
AtlasOfTime/
  App/
  Features/
    Home/
      DI/
      Presentation/
    Settings/
      Presentation/
  Domain/
    Entities/
    Protocols/
    UseCases/
  Data/
    Cache/
    DataSources/
    Decoding/
    Loaders/
    Repositories/
  Shared/
    DesignSystem/
    Errors/
    Localization/
    Settings/
    Utils/
  Resources/
```

## Boundary Rules

- `App` owns app startup and app-shell composition only.
- `Features/Home` owns Home-specific presentation, map rendering, and feature DI glue.
- `Features/Settings` owns settings presentation only.
- `Domain` owns app-wide entities, use cases, and repository protocols.
- `Data` owns concrete data access, decoding, cache, and repository implementations.
- `Shared` is for cross-feature support code, not feature UI moved out for convenience.

## Package Readiness

The current structure is package-friendly in these areas:

1. `Features/Home`
   - already has local `Presentation` and `DI`
   - strongest candidate for future package extraction
2. `Features/Settings`
   - presentation is isolated
   - can become a package once settings dependencies are formalized
3. `App`
   - remains the composition layer above packages

## Next Modularization Targets

### 1. Home Feature Package

Best first extraction target:

```text
Features/Home
```

Reason:
- clear ownership
- limited surface area
- internal UI and DI are already grouped
- depends mostly on shared `Domain` contracts and app-level composition

Expected future shape:

```text
HomeFeature/
  Sources/
    HomeFeature/
      Presentation/
      DI/
```

### 2. Settings Feature Package

Second extraction target:

```text
Features/Settings
```

Reason:
- presentation is isolated
- app-language, appearance, and preferences controllers are still shared app services
- package extraction is straightforward once those service contracts are explicit

### 3. Shared Support Split

Do not split `Shared` into packages blindly.

Only extract when a subgroup has a stable responsibility, for example:
- localization support
- design system support
- settings/preferences support

Current recommendation:
- keep `Shared` as source-level shared code for now
- extract only after duplication or ownership pressure appears

## What Should Not Move Yet

- `Domain`
- `Data`
- top-level `DI`

Reason:
- these layers still act as app-wide foundations
- premature package extraction would increase dependency-management overhead before the feature boundaries need it

## Extraction Order

1. `Features/Home`
2. `Features/Settings`
3. selected `Shared` subgroups only if justified
4. broader `Domain` / `Data` modularization later, if the app grows enough to need it

## Review Standard

Before creating a new package, verify:
- ownership is clear
- the folder already has a stable public surface
- cross-package dependencies are directional and minimal
- the move reduces coupling instead of just changing paths
