import SwiftUI

struct CountryDetailScene: View {
    @StateObject private var viewModel: CountryDetailViewModel
    @Environment(\.atlasTheme) private var theme

    init(viewModel: CountryDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

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

            detailSection(
                title: String(localized: AppStrings.Home.Detail.overviewTitle),
                body: result.overview
            )

            if let territorialContext = result.territorialContext,
               !territorialContext.isEmpty {
                detailSection(
                    title: String(localized: AppStrings.Home.Detail.territorialContextTitle),
                    body: territorialContext
                )
            }

            if let politicalContext = result.politicalContext,
               !politicalContext.isEmpty {
                detailSection(
                    title: String(localized: AppStrings.Home.Detail.politicalContextTitle),
                    body: politicalContext
                )
            }

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

    private func detailSection(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(theme.primaryText)

            Text(body)
                .font(.body)
                .foregroundStyle(theme.primaryText)
        }
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
            CountryDetailPreviewFactory.makeScene(snapshot: previewSnapshot)
        }
    }

    private static var previewSnapshot: HistoricalCountrySnapshot {
        HistoricalCountrySnapshot(
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
    }
}
#endif
