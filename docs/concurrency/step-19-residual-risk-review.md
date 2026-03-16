# Step 19 Residual Risk Review

## Current Stable Areas

### Presentation task ownership
- `AtlasViewModel` owns bootstrap and active load tasks explicitly.
- Debounced work is cancelled during teardown.
- Latest-request-wins behavior is protected by request tokens, not cancellation timing alone.

### Data coordination
- `DefaultBorderRepository` deduplicates in-flight loads per year.
- Cancellation is checked before cache mutation.
- Loading work is separated from repository coordination through `BorderSnapshotLoading`.

### Test coverage
- Repository caching and in-flight deduplication have direct concurrency tests.
- Repository cancellation is covered with an event-driven gated loader.
- ViewModel stale-result behavior is covered with an event-driven signaling repository.
- Use cases have task-boundary contract coverage under Swift 6.

## Residual Risks

### Medium: synchronous decode stages remain cooperative, not preemptive
Files:
- `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/Data/Loaders/BorderSnapshotLoader.swift`
- `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/Data/DataSources/BundleDataSource.swift`

Details:
- File read, gunzip, and GeoJSON decoding are still synchronous stages.
- Cancellation is checked between stages, but not during the synchronous work itself.
- This is acceptable at the current scale unless profiling shows latency or responsiveness issues.

Recommendation:
- Do not refactor further without evidence from profiling or runtime UX issues.

### Medium: runtime execution on a concrete simulator is still unverified in this environment
Details:
- `build` and `build-for-testing` succeed under Swift 6.
- `xcodebuild test` could not be executed because CoreSimulator is unavailable and no concrete simulator destination is exposed.

Recommendation:
- Re-run Step 18 once CoreSimulator is healthy.
- Treat that as the main remaining operational validation gap.

### Low: future regressions are more likely to come from new async code than current code
Files:
- `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/Presentation/AtlasViewModel.swift`
- `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTime/Data/Repositories/DefaultBorderRepository.swift`
- `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTimeTests/AtlasViewModelDITests.swift`
- `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTimeTests/BorderRepositoryConcurrencyTests.swift`
- `/Users/hoorad/Documents/AtlasOfTime/AtlasOfTimeTests/UseCaseConcurrencyContractTests.swift`

Details:
- The current concurrency model is coherent.
- The main risk is a future contributor reintroducing fire-and-forget tasks, timing-based tests, or weaker repository implementations.

Recommendation:
- Keep using the concurrency review checklist and event-driven async tests for future changes.

## What Not To Do Next

- Do not add more concurrency abstraction layers without a concrete problem.
- Do not move more code to `@MainActor` as a convenience.
- Do not refactor synchronous decode stages preemptively without performance evidence.
- Do not churn stable task-ownership code for naming/style-only reasons.

## Recommended Next Move

1. Restore a working CoreSimulator environment.
2. Run `xcodebuild test` against a concrete simulator destination.
3. Only after runtime execution is available, decide whether any remaining issues are operational, performance-related, or code-related.

## Closeout Assessment

The codebase is in a materially better state than the baseline:
- Swift 6 is enabled at the project level.
- Concurrency boundaries are explicit.
- Cancellation and stale-work behavior are tested more directly.
- Remaining risk is mostly operational validation, not architectural ambiguity.
