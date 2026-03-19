import SwiftUI

struct CountryDetailScene: View {
    @ObservedObject var viewModel: CountryDetailViewModel
    @Environment(\.atlasTheme) private var theme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                headerSection

                if viewModel.isLoading {
                    loadingSection
                } else if let result = viewModel.summaryResult {
                    contentSection(result)
                } else if let errorMessage = viewModel.errorMessage, !errorMessage.isEmpty {
                    errorSection(errorMessage)
                } else {
                    emptySection
                }
            }
            .padding(16)
        }
        .background(theme.groupedBackground.ignoresSafeArea())
        .navigationTitle(viewModel.snapshot.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadIfNeeded()
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(viewModel.snapshot.year)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(theme.primaryText)

            if let formalName = viewModel.snapshot.formalName,
               formalName != viewModel.snapshot.displayName {
                Text(formalName)
                    .font(.subheadline)
                    .foregroundStyle(theme.secondaryText)
            }

            HStack(spacing: 8) {
                chip(
                    title: String(localized: AppStrings.Home.Detail.nameConfidenceTitle),
                    value: localizedConfidence(viewModel.snapshot.nameConfidence)
                )

                if let primaryExtent = viewModel.snapshot.extents.first {
                    chip(
                        title: String(localized: AppStrings.Home.Detail.borderConfidenceTitle),
                        value: localizedConfidence(primaryExtent.borderConfidence)
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .atlasCardSurface(cornerRadius: 20)
    }

    private var loadingSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            ProgressView()
                .controlSize(.regular)

            Text(AppStrings.Home.Detail.loadingTitle)
                .font(.headline)
                .foregroundStyle(theme.primaryText)

            Text(AppStrings.Home.Detail.loadingMessage)
                .font(.subheadline)
                .foregroundStyle(theme.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .atlasCardSurface(cornerRadius: 20)
    }

    private func contentSection(_ result: CountrySummaryResult) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(result.title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(theme.primaryText)

            Text(result.summary)
                .font(.body)
                .foregroundStyle(theme.primaryText)

            if !result.keyFacts.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text(AppStrings.Home.Detail.keyFactsTitle)
                        .font(.headline)
                        .foregroundStyle(theme.primaryText)

                    ForEach(result.keyFacts, id: \.self) { fact in
                        HStack(alignment: .top, spacing: 8) {
                            Circle()
                                .fill(theme.secondaryText)
                                .frame(width: 6, height: 6)
                                .padding(.top, 6)

                            Text(fact)
                                .foregroundStyle(theme.primaryText)
                        }
                    }
                }
            }

            if let confidenceNote = result.confidenceNote, !confidenceNote.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text(AppStrings.Home.Detail.confidenceNoteTitle)
                        .font(.headline)
                        .foregroundStyle(theme.primaryText)

                    Text(confidenceNote)
                        .font(.subheadline)
                        .foregroundStyle(theme.secondaryText)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .atlasCardSurface(cornerRadius: 20)
    }

    private func errorSection(_ errorMessage: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(AppStrings.Home.Detail.errorTitle)
                .font(.headline)
                .foregroundStyle(theme.primaryText)

            Text(errorMessage)
                .font(.subheadline)
                .foregroundStyle(theme.secondaryText)

            Button(AppStrings.Home.Detail.retryButtonTitle) {
                viewModel.reload()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .atlasCardSurface(cornerRadius: 20)
    }

    private var emptySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(AppStrings.Home.Detail.emptyTitle)
                .font(.headline)
                .foregroundStyle(theme.primaryText)

            Text(AppStrings.Home.Detail.emptyMessage)
                .font(.subheadline)
                .foregroundStyle(theme.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .atlasCardSurface(cornerRadius: 20)
    }

    private func chip(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(theme.secondaryText)

            Text(value)
                .font(.caption.weight(.semibold))
                .foregroundStyle(theme.primaryText)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(theme.selectionFill, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func localizedConfidence(_ confidence: HistoricalConfidence) -> String {
        switch confidence {
        case .high:
            String(localized: AppStrings.Home.confidenceHigh)
        case .medium:
            String(localized: AppStrings.Home.confidenceMedium)
        case .low:
            String(localized: AppStrings.Home.confidenceLow)
        case .unknown:
            String(localized: AppStrings.Home.confidenceUnknown)
        }
    }
}

#if DEBUG
struct CountryDetailScene_Previews: PreviewProvider {
    @MainActor
    static var previews: some View {
        NavigationStack {
            CountryDetailScene(viewModel: makeViewModel())
        }
    }

    @MainActor
    private static func makeViewModel() -> CountryDetailViewModel {
        let snapshot = HistoricalCountrySnapshot(
            id: "preview:ottoman",
            entityID: "entity:ottoman",
            year: 1683,
            displayName: "Ottoman Empire",
            shortDisplayName: "Ottomans",
            formalName: "Ottoman Empire",
            nameConfidence: .medium,
            extents: [
                HistoricalExtent(
                    id: "extent:ottoman:1683",
                    extentType: .control,
                    borderModel: .lineWithUncertainty,
                    borderPrecisionRank: 2,
                    borderConfidence: .medium,
                    polygons: []
                )
            ],
            relationships: [
                HistoricalRelationship(
                    id: "relationship:ottoman:crimea",
                    type: .subjectOf,
                    targetEntityID: "entity:crimea",
                    targetDisplayName: "Crimean Khanate",
                    basis: .assertedBySource,
                    confidence: .medium
                )
            ],
            sourceReferences: [
                HistoricalSourceReference(
                    id: "source:preview",
                    title: "Preview Historical Dataset"
                )
            ]
        )

        let generator = PreviewCountrySummaryGenerator()
        let useCase = GenerateCountrySummary(generator: generator)
        return CountryDetailViewModel(snapshot: snapshot, generateCountrySummary: useCase)
    }
}

private struct PreviewCountrySummaryGenerator: CountrySummaryGenerating {
    func generateSummary(for request: CountrySummaryRequest) async throws -> CountrySummaryResult {
        CountrySummaryResult(
            title: request.displayName,
            summary: "\(request.displayName) is shown here for \(request.year). This preview summary is generated through the same app-owned boundary that the real foundation-model adapter will use.",
            keyFacts: [
                "Name confidence: \(request.nameConfidence.rawValue)",
                "Border confidence: \(request.borderConfidence.rawValue)",
                "Relationships included: \(request.relationships.count)"
            ],
            confidenceNote: "Preview content only."
        )
    }
}
#endif
