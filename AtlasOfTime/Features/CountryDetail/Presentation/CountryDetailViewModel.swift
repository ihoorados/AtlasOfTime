import Combine
import Foundation
import CoreAtlasDomain

@MainActor
final class CountryDetailViewModel: ObservableObject {
    @Published private(set) var summaryResult: CountrySummaryResult?
    @Published private(set) var errorMessage: String?
    @Published private(set) var isLoading = false

    let snapshot: HistoricalCountrySnapshot

    private let generateCountrySummary: GenerateCountrySummary
    private var loadTask: Task<Void, Never>?
    private var hasLoaded = false

    init(
        snapshot: HistoricalCountrySnapshot,
        generateCountrySummary: GenerateCountrySummary
    ) {
        self.snapshot = snapshot
        self.generateCountrySummary = generateCountrySummary
    }

    func loadIfNeeded() {
        guard !hasLoaded else { return }
        hasLoaded = true
        load()
    }

    func reload() {
        load()
    }

    deinit {
        loadTask?.cancel()
    }

    private func load() {
        loadTask?.cancel()
        isLoading = true
        errorMessage = nil

        loadTask = Task { [weak self] in
            guard let self else { return }

            do {
                let result = try await generateCountrySummary.execute(for: snapshot)
                try Task.checkCancellation()
                summaryResult = result
                errorMessage = nil
            } catch is CancellationError {
                return
            } catch {
                summaryResult = nil
                errorMessage = AppError.wrap(error).userMessage
            }

            isLoading = false
        }
    }
}
