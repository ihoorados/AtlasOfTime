# Add a New Feature DI Container

## Goal
Follow the same DI pattern used by Atlas feature without adding framework complexity.

## Required Structure
1. Add feature container under:
   - `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/Presentation/DI`
2. Container must use constructor injection only.
3. Container should conform to:
   - `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/DI/FeatureDIContainerBlueprint.swift`

## Lifetime Checklist
- App-scoped:
  - repositories, cache, data sources, infra adapters.
- Feature-scoped:
  - feature container and use-case wiring values.
- View-scoped:
  - feature ViewModel instance (`make...ViewModel()` returns new object).

## Wiring Steps
1. Build data dependencies in `DataDIContainer`.
2. Build domain use-cases in `DomainDIContainer`.
3. Build feature container in `AppDIContainer` through a dedicated private factory method.
4. Expose only required public factory method(s) from `AppDIContainer`.

## Guardrails
- Do not add generic `resolve()` APIs.
- Do not inject concrete data implementations directly into views.
- Keep container API minimal; remove unused factories.

