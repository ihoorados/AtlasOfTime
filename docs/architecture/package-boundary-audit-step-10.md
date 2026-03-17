# Package Boundary Audit: Step 10

## Scope

- `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/App`
- `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/Features`
- `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/Shared`

## Result

The current source layout is materially cleaner after the `App`, `Features`, `Shared/Foundation`, and `Shared/AppSupport` split.

No new runtime coupling problems were found between:

- `Features/Home`
- `Features/Settings`
- `Shared/Foundation`
- `Shared/AppSupport`

The main remaining package-readiness blocker is preview composition in the app shell.

## Primary Blocker

### `App/RootTabScreen` preview still depends on app-root preview DI

File:

- `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/App/RootTabScreen.swift`

Current preview wiring:

```swift
RootTabScreen(
    viewModel: PreviewAppDIContainer().makeAtlasViewModel(),
    appearanceController: AppearanceController(),
    languageController: AppLanguageController(),
    preferencesController: AppPreferencesController()
)
```

Why this matters:

- `Features/Home` already owns `HomePreviewFactory`
- `Features/Settings` already owns `SettingsPreviewFactory`
- the app shell preview still reaches into the legacy app preview container instead of composing those feature-local preview entry points

That means preview ownership is not fully aligned with the new package-ready boundaries yet.

## Secondary Observations

1. `Shared/AppSupport` is intentionally app-owned
   - this is acceptable
   - it should not be treated as generic reusable infrastructure

2. `Features/Settings` depends on shared app controllers
   - `AppearanceController`
   - `AppLanguageController`
   - `AppPreferencesController`
   - this is currently acceptable because `Settings` is still presentation-only
   - package extraction would later benefit from small service-facing contracts if those dependencies need to be decoupled

3. `Features/Home` depends on app-owned error presentation
   - `AppError`
   - this is acceptable for now
   - if `Home` becomes a real package before broader app support is extracted, error presentation may need a narrower boundary

## Recommended Next Move

1. remove `PreviewAppDIContainer` usage from `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/App/RootTabScreen.swift`
2. make the app-shell preview compose feature-local preview factories instead
3. reassess whether any remaining preview-only app-root DI should survive at all

## Not Recommended Yet

- splitting `Shared/AppSupport` into packages
- extracting `Domain` or `Data`
- introducing new protocols only to satisfy hypothetical packaging
