# Swift 6 Concurrency Migration Plan

## Purpose

This document defines the migration plan for moving AtlasOfTime from the current Swift 5 concurrency posture toward Swift 6 language mode with explicit, reviewable isolation semantics.

This is not a "flip the version and patch errors" migration.

The goal is to:

- preserve architecture quality
- avoid low-quality compiler appeasement
- improve ownership and isolation clarity
- keep changes small and reviewable

## Current State

Current build posture:

```text
SWIFT_VERSION = 5.0
SWIFT_APPROACHABLE_CONCURRENCY = YES
SWIFT_STRICT_CONCURRENCY = targeted
```

Current architecture state:

- `Presentation` uses explicit `@MainActor` where UI ownership is real
- `Domain` models are largely value-oriented and `Sendable`
- `Data` uses actors for mutable coordination
- app target no longer relies on default `MainActor` isolation
- repository loading path supports:
  - cache reuse
  - in-flight request deduplication
  - cooperative cancellation

This is a strong baseline for migration.

## Migration Principles

### 1. Type-level isolation must carry the design

Prefer:

```swift
@MainActor
final class AtlasViewModel: ObservableObject { ... }
```

and:

```swift
actor DefaultBorderRepository: BorderRepository { ... }
```

Do not rely on project-wide fallback behavior to define architecture.

### 2. Fix architecture first, then diagnostics

Every concurrency diagnostic should be interpreted as one of:

- sendability ambiguity
- isolation ambiguity
- ownership ambiguity

The goal is not to silence errors quickly. The goal is to improve the design that produced them.

### 3. Prefer explicit, narrow fixes

Preferred fixes:

- value semantics
- actor isolation
- explicit `@MainActor` on UI state owners
- clearer dependency boundaries

Avoid broad, low-signal fixes unless there is a documented reason.

## Migration Phases

### Phase 1: Baseline Hardening

Status: complete enough to proceed

Completed work:

- task ownership clarified in `AtlasViewModel`
- debounce teardown made explicit
- repository coordination separated from expensive loading work
- same-year in-flight requests deduplicated
- cancellation propagated through loading path
- targeted strict concurrency enabled
- app target default `MainActor` isolation removed

### Phase 2: Diagnostic Audit Under Swift 5 + Targeted Strictness

Goal:

- identify remaining weak spots before enabling Swift 6 language mode

Audit focus:

- reference types captured across async boundaries
- protocol abstractions that are implicitly assumed safe
- non-sendable values captured in task closures
- stateful helper types without a clear concurrency identity

Expected hotspots in this codebase:

- DI containers that retain reference dependencies
- protocol-backed services used inside `Sendable` use cases
- test doubles that may need stronger explicit isolation as diagnostics tighten

### Phase 3: Controlled Swift 6 Enablement

Goal:

- enable Swift 6 in a controlled branch or validation path
- fix by subsystem rather than by random compiler order

Recommended order:

1. `Domain`
2. `Data`
3. `Presentation`
4. tests and previews

Reason:

- `Domain` should be the easiest to keep value-oriented
- `Data` defines coordination and ownership rules
- `Presentation` depends on those boundaries

### Phase 4: Remove Migration Crutches

Goal:

- ensure no temporary workaround is mistaken for architecture

Review any temporary:

- targeted suppressions
- wrapper types created only for migration
- narrow annotations added to contain blast radius

Anything added only to get through migration should be either:

- justified as permanent design
- or removed

## Acceptable Fix Patterns

### UI state owner

```swift
@MainActor
final class SomeViewModel: ObservableObject { ... }
```

Use when:

- state is rendered directly by SwiftUI
- mutations are UI-facing

### Shared mutable coordinator

```swift
actor SomeRepository { ... }
```

Use when:

- mutable shared state must be coordinated
- in-flight or cache maps are owned by one subsystem

### Value transport object

```swift
struct Snapshot: Sendable {
    let year: Int
}
```

Use when:

- data crosses async boundaries
- no shared mutable identity is needed

## Anti-Patterns During Migration

### 1. Blanket `@MainActor`

Avoid:

```swift
@MainActor
final class DefaultBorderRepository { ... }
```

Why:

- data-layer concerns are not UI concerns
- this hides architecture problems instead of solving them

### 2. Casual `@unchecked Sendable`

Avoid:

```swift
final class SomeType: @unchecked Sendable { ... }
```

unless there is:

- a clear safety invariant
- a narrow scope
- a documented reason

### 3. Random error-order migration

Avoid fixing diagnostics purely in compiler output order without subsystem thinking.

Why:

- low-quality fixes accumulate quickly
- the architecture drifts under pressure

## Review Questions for Swift 6 Migration

For each migration diff, ask:

1. Is this fix expressing ownership or just appeasing the compiler?
2. Should this type be a value, an actor, or a UI-isolated state owner?
3. Is `@MainActor` justified by UI semantics?
4. Is a reference type crossing async boundaries without a defensible isolation story?
5. If `@unchecked Sendable` is proposed, what exact invariant makes it safe?

## Recommended Execution Strategy

When actual Swift 6 enablement starts:

1. make one focused subsystem change
2. build
3. fix resulting diagnostics
4. rebuild
5. only then move to the next subsystem

Do not batch unrelated concurrency fixes across the whole project at once.

## Definition of Done

Swift 6 migration is complete when:

- type-level isolation is explicit
- `Sendable` usage is defensible
- no architectural layer depends on broad fallback executor assumptions
- tests and previews compile under the chosen language mode
- workarounds introduced only for migration are reviewed and either justified or removed
