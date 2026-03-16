# Concurrency Review Checklist

Use this checklist when reviewing async, actor, or task-related changes in AtlasOfTime.

## Type Ownership

1. Is this type UI-bound, shared mutable coordination state, or a pure value?
2. If `@MainActor` is used, is it justified by UI ownership rather than compiler convenience?
3. If an `actor` is used, is it protecting mutable shared state rather than acting as a generic work container?

## Task Ownership

1. Does every `Task {}` have an owner?
2. Is there an explicit cancellation path?
3. Can stale work still complete, and if so, is that behavior intentional?

## Repository and Loading Paths

1. Is caching separated from expensive decode work?
2. If overlapping requests for the same key are possible, is in-flight deduplication needed?
3. Is heavy work being executed behind an actor boundary that only needs to coordinate state?

## Domain and Value Modeling

1. Are values crossing concurrency boundaries `Sendable`?
2. Is Domain free from UI and infrastructure executor assumptions?
3. Are reference types being captured across async boundaries without clear isolation?

## Testing

1. Does the test suite verify concurrency contracts, not just final outcomes?
2. Are ordering and overlap scenarios tested with deterministic delays where needed?
3. Are loader or repository seams used directly when the contract lives in Data rather than Presentation?
