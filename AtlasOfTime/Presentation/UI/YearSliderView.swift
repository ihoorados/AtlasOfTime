import SwiftUI

struct YearSliderView: View {
    @Binding var selectedYear: Int
    let availableYears: [Int]
    @Environment(\.atlasTheme) private var theme
    @Environment(\.atlasShowYearRangeLabels) private var showYearRangeLabels

    private var years: [Int] {
        availableYears.sorted()
    }

    var body: some View {
        VStack(spacing: 8) {
            Slider(value: sliderIndexBinding, in: sliderRange, step: 1)
                .tint(theme.primaryText)
                .disabled(years.count < 2)
                .accessibilityLabel(AppStrings.Accessibility.Timeline.yearSliderLabel)
                .accessibilityValue(selectedYearAccessibilityValue)
                .accessibilityHint(AppStrings.Accessibility.Timeline.yearSliderHint)

            if showYearRangeLabels {
                HStack {
                    Text(years.first.map(String.init) ?? "--")
                    Spacer()
                    Text(years.last.map(String.init) ?? "--")
                }
                .font(.caption)
                .foregroundStyle(theme.secondaryText)
                .accessibilityHidden(true)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(theme.groupedBackground)
        )
        // Historical time flows from earlier to later years regardless of UI language.
        .environment(\.layoutDirection, .leftToRight)
    }

    private var sliderRange: ClosedRange<Double> {
        let upperBound = max(Double(years.count - 1), 1)
        return 0...upperBound
    }

    private var sliderIndexBinding: Binding<Double> {
        Binding(
            get: {
                guard !years.isEmpty else { return 0 }
                if let exactIndex = years.firstIndex(of: selectedYear) {
                    return Double(exactIndex)
                }
                return Double(nearestIndex(to: selectedYear))
            },
            set: { newValue in
                guard !years.isEmpty else { return }
                let clampedIndex = min(max(Int(newValue.rounded()), 0), years.count - 1)
                selectedYear = years[clampedIndex]
            }
        )
    }

    private func nearestIndex(to year: Int) -> Int {
        guard let first = years.first else { return 0 }

        var bestIndex = 0
        var bestDistance = abs(first - year)

        for (index, candidate) in years.enumerated() {
            let distance = abs(candidate - year)
            if distance < bestDistance {
                bestDistance = distance
                bestIndex = index
            }
        }

        return bestIndex
    }

    private var selectedYearAccessibilityValue: String {
        LocalizedStringFormat.resolve(
            AppStrings.Accessibility.Timeline.selectedYearFormat,
            locale: .current,
            Int64(selectedYear)
        )
    }
}
