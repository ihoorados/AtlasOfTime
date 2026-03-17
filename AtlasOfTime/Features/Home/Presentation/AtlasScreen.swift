import SwiftUI

struct AtlasScreen: View {
    @ObservedObject var viewModel: AtlasViewModel
    @Environment(\.atlasTheme) private var theme
    @Environment(\.atlasShowLoadingIndicator) private var showLoadingIndicator

    var body: some View {
        ZStack(alignment: .bottom) {
            AtlasMapView(snapshot: viewModel.renderSnapshot)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .firstTextBaseline) {
                    Text(viewModel.displayYear == 0 ? String(localized: AppStrings.Common.unavailableValue) : "\(viewModel.displayYear)")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(theme.primaryText)

                    Spacer()

                    if viewModel.isLoading && showLoadingIndicator {
                        ProgressView()
                            .controlSize(.small)
                    }
                }

                YearSliderView(
                    selectedYear: Binding(
                        get: { viewModel.displayYear },
                        set: { viewModel.onYearChanged(year: $0) }
                    ),
                    availableYears: viewModel.availableYears
                )

                if let message = viewModel.errorMessage, !message.isEmpty {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
            .padding(16)
            .atlasCardSurface(cornerRadius: 16)
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .onAppear {
            viewModel.onAppear()
        }
    }
}

#if DEBUG
struct AtlasScreen_Previews: PreviewProvider {
    @MainActor
    static var previews: some View {
        Group {
            atlasPreview(localeIdentifier: "en", layoutDirection: .leftToRight)
                .previewDisplayName(PreviewDisplayName.english("Home Panel"))

            atlasPreview(localeIdentifier: "fa", layoutDirection: .rightToLeft)
                .previewDisplayName(PreviewDisplayName.persianRTL("Home Panel"))
        }
    }

    @MainActor
    private static func atlasPreview(
        localeIdentifier: String,
        layoutDirection: LayoutDirection
    ) -> some View {
        AtlasScreen(viewModel: HomePreviewFactory.makeViewModel())
            .environment(\.locale, Locale(identifier: localeIdentifier))
            .environment(\.layoutDirection, layoutDirection)
    }
}
#endif
