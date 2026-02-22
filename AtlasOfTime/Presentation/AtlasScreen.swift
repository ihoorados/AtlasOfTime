import SwiftUI

struct AtlasScreen: View {
    @ObservedObject var viewModel: AtlasViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            AtlasMapView(snapshot: viewModel.renderSnapshot)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .firstTextBaseline) {
                    Text(viewModel.displayYear == 0 ? "--" : "\(viewModel.displayYear)")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .monospacedDigit()

                    Spacer()

                    if viewModel.isLoading {
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
                        .foregroundColor(.red)
                }
            }
            .padding(16)
            .background(
                .ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .onAppear {
            viewModel.onAppear()
        }
    }
}
