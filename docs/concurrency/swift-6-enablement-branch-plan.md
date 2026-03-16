# Swift 6 Enablement Branch Plan

## Purpose

This document defines the first real Swift 6 enablement branch plan for AtlasOfTime.

It is intended to convert the current migration readiness into a controlled branch execution plan.

This plan assumes:

- targeted strict concurrency is already enabled
- app target no longer relies on default `MainActor` isolation
- the Swift 6 audit override did not surface source-level diagnostics in this environment

## Branch Goal

Create a dedicated branch to enable Swift 6 language mode in project settings without mixing unrelated work.

Recommended branch name:

```text
codex/swift6-enable
```

## Primary Change

The branch should introduce the project-level language mode change:

```text
SWIFT_VERSION = 6.0
```

This should be done in the actual project configuration, not only via command-line override.

## Scope Rules

### Allowed changes

- explicit isolation fixes directly required by Swift 6 diagnostics
- `Sendable` clarifications directly required by Swift 6 diagnostics
- small ownership refactors directly required by migration
- test helper isolation updates required for Swift 6 compatibility
- documentation updates tied to migration

### Disallowed changes

- unrelated feature work
- product/UI redesign
- broad architectural refactors not justified by migration diagnostics
- opportunistic cleanup that makes the branch harder to review

## Subsystem Order

Migration fixes should be handled in this order:

1. `Domain`
2. `Data`
3. `Presentation`
4. tests and previews

Reason:

- `Domain` should remain the most value-oriented layer
- `Data` defines coordination and ownership rules
- `Presentation` depends on those decisions
- tests and previews should follow the real architecture

## Review Standard

Every Swift 6 migration change should answer:

1. Is this fix expressing ownership clearly?
2. Is `@MainActor` used because the type is truly UI-bound?
3. Is an actor used because mutable shared state actually needs coordination?
4. Is a `Sendable` change justified by real transfer semantics?

If the answer is "this only makes the compiler stop complaining," the fix quality is too low.

## Migration Guardrails

### Prefer

```swift
@MainActor
final class UIStateOwner { ... }
```

```swift
actor SharedCoordinator { ... }
```

```swift
struct Snapshot: Sendable { ... }
```

### Avoid

```swift
@MainActor
final class DefaultBorderRepository { ... }
```

```swift
final class SomeType: @unchecked Sendable { ... }
```

unless there is a narrow, documented, defensible reason.

## Execution Plan

### Phase 1: Branch creation

1. create `codex/swift6-enable`
2. commit current migration docs and concurrency hardening first

### Phase 2: Setting flip

1. change `SWIFT_VERSION` to `6.0`
2. build app target
3. build test targets

### Phase 3: Diagnostic handling

For each new diagnostic:

1. classify it as:
   - sendability
   - actor isolation
   - task capture
   - reference ownership
2. fix it in subsystem order
3. rebuild after each focused batch

### Phase 4: Closure

Before merging:

- app build succeeds
- test build succeeds
- no architectural fallback settings were reintroduced
- migration-only workarounds are reviewed and documented

## Acceptance Criteria

The Swift 6 enablement branch is acceptable when:

- `SWIFT_VERSION = 6.0` is set in project configuration
- the app target builds successfully
- test targets build successfully
- concurrency semantics remain explicit at the type level
- no regression to broad fallback executor assumptions occurs
- review can explain every migration change as an architectural clarification, not compiler appeasement

## Recommended Follow-Up

Once the branch is created and Swift 6 is enabled in project settings, the next work item should be a real diagnostic pass over the changed project configuration with fixes applied in subsystem order.
