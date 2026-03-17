# DI Boundary Audit: Step 12

## Scope

- `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/DI`

## Files Reviewed

- `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/DI/AppDIContainer.swift`
- `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/DI/AtlasDIProviding.swift`
- `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/DI/DataDIContainer.swift`
- `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/DI/DomainDIContainer.swift`
- `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/DI/FeatureDIContainerBlueprint.swift`
- `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/DI/PreviewAppDIContainer.swift`

## Result

The current DI layer is mostly still serving real app-foundation responsibilities.

The only clearly stale type is:

- `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/DI/PreviewAppDIContainer.swift`

## Classification

### Keep as App Foundations

#### `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/DI/AppDIContainer.swift`

Keep at app level.

Reason:

- this is the composition root
- it assembles `DataDIContainer`, `DomainDIContainer`, and feature DI
- this is exactly the kind of type that should stay above feature packages

#### `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/DI/AtlasDIProviding.swift`

Keep at app level for now.

Reason:

- it represents the app-shell-facing DI surface
- it is still tied to `AtlasViewModel`
- if the app later supports multiple feature roots, this protocol may need renaming or widening, but it is not the current blocker

#### `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/DI/DataDIContainer.swift`

Keep at app foundation level for now.

Reason:

- it owns concrete repository assembly
- it ties together app-wide data infrastructure
- extracting it prematurely would blur the current `Data` boundary instead of clarifying it

#### `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/DI/DomainDIContainer.swift`

Keep at app foundation level for now.

Reason:

- it is the bridge from repository abstractions to use cases
- it is still a clean app-wide assembly layer
- moving it now would not improve modularity

### Feature-Adjacent But Acceptable

#### `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/DI/FeatureDIContainerBlueprint.swift`

This is acceptable where it is, but it is not strongly justified as a long-term app-global type.

Reason:

- it is generic and lightweight
- only feature DI currently uses it
- it could later move into a shared foundation or be removed entirely if feature DI stops needing the protocol

This is not urgent.

### Legacy / Remove Next

#### `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/DI/PreviewAppDIContainer.swift`

This is now legacy.

Reason:

- `Features/Home` now owns `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/Features/Home/DI/HomePreviewFactory.swift`
- `Features/Settings` now owns `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/Features/Settings/DI/SettingsPreviewFactory.swift`
- `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/App/RootTabScreen.swift` preview no longer depends on `PreviewAppDIContainer`

That means the app-level preview DI container no longer serves the current package-ready direction.

## Recommended Next Move

1. remove `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/DI/PreviewAppDIContainer.swift`
2. validate that nothing in app code, previews, or tests still references it
3. then reassess whether `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/DI/FeatureDIContainerBlueprint.swift` still earns its own global place

## Not Recommended Yet

- moving `AppDIContainer` into a feature
- splitting `DataDIContainer`
- splitting `DomainDIContainer`
- redesigning DI protocols without a concrete package-extraction need
