# Swift 6 Diagnostic Audit

## Audit Scope

Date:

- 2026-03-15

Workspace:

- `/Users/hoorad/Documents/AtlasOfTime`

Audit command:

```bash
xcodebuild \
  -project /Users/hoorad/Documents/AtlasOfTime/AtlasOfTime.xcodeproj \
  -scheme AtlasOfTime \
  -sdk iphonesimulator \
  -configuration Debug \
  -derivedDataPath /tmp/AtlasSwift6Audit \
  build-for-testing \
  SWIFT_VERSION=6.0
```

## Result Summary

Result:

- No source-level Swift 6 diagnostics were emitted during the audit build in this environment.

Important qualification:

- The build output included substantial Xcode/CoreSimulator environment noise unrelated to app source:
  - simulator service connection failures
  - provisioning profile parsing failures
  - Xcode plist detector warnings

These are environment/tooling issues, not Swift 6 migration blockers in AtlasOfTime source.

## What This Means

This audit is a positive signal, not a final migration guarantee.

It indicates that, under the current codebase state:

- explicit `@MainActor` usage in Presentation is coherent
- actor-backed coordination in Data is coherent
- current `Sendable` modeling is acceptable to the Swift 6 compiler path used in this audit
- recent improvements around task ownership, deduplication, and cancellation reduced likely migration friction

## No Immediate Compiler Findings

The audit did **not** surface source diagnostics in these categories:

- sendability violations
- actor isolation violations
- non-sendable captures in `Task` closures
- explicit Swift 6 concurrency errors in test targets

This is better than a typical first migration audit and suggests the architecture cleanup has already removed much of the low-quality migration debt.

## Residual Risk Areas

Even though the compiler did not emit source diagnostics in this audit, these areas remain the most likely future migration hotspots as concurrency rules tighten further or the codebase grows.

### 1. Protocol existentials inside `Sendable` use cases

Relevant code:

```swift
struct LoadYearIndex: Sendable {
    private let repository: any YearIndexRepository
}

struct LoadBordersForYear: Sendable {
    private let repository: any BorderRepository
}
```

Why watch this:

- protocol-based reference dependencies inside `Sendable` wrappers are worth re-checking under any future changes to repository contracts or stored state

### 2. Unstructured task capture sites in `AtlasViewModel`

Relevant code sites:

- `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/Presentation/AtlasViewModel.swift`

Current pattern is acceptable, but future changes should continue to audit:

- what is captured
- whether the owner is explicit
- whether cancellation remains complete

### 3. Test doubles and helper actors

Relevant files:

- `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTimeTests/AtlasViewModelDITests.swift`
- `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTimeTests/BorderRepositoryConcurrencyTests.swift`

Why watch this:

- test infrastructure often becomes the first place where looser async assumptions creep back in

## Interpreted Architectural Outcome

Based on this audit, the codebase currently appears ready for a controlled Swift 6 migration branch.

That does **not** mean the migration should be flipped directly on `main`.

It means the next migration step can reasonably move from:

- planning and hardening

to:

- a controlled Swift 6 enablement branch with subsystem-by-subsystem validation

## Recommended Next Step

Recommended next technical step:

1. create a Swift 6 migration branch
2. enable Swift 6 in project settings, not just command-line override
3. rebuild
4. address any branch-specific diagnostics by subsystem order:
   - Domain
   - Data
   - Presentation
   - tests and previews

## Audit Conclusion

Conclusion:

- AtlasOfTime does not currently show obvious Swift 6 concurrency breakage under the audit path used here.
- The prior refactor work has meaningfully reduced migration risk.
- The next move should be a controlled enablement branch rather than more speculative cleanup.
