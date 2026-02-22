import SwiftUI

struct YearSliderView: View {
    @Binding var selectedYear: Int
    let availableYears: [Int]

    private var years: [Int] {
        availableYears.sorted()
    }

    var body: some View {
        VStack(spacing: 8) {
            Slider(value: sliderIndexBinding, in: sliderRange, step: 1)
                .disabled(years.count < 2)

            HStack {
                Text(years.first.map(String.init) ?? "--")
                Spacer()
                Text(years.last.map(String.init) ?? "--")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
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
}
