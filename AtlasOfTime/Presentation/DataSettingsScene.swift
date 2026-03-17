import SwiftUI

struct DataSettingsScene: View {
    var body: some View {
        Form {
            datasetSection
            loadingSection
        }
        .navigationTitle("Data")
    }

    private var datasetSection: some View {
        Section {
            LabeledContent("Source") {
                Text("Bundled")
                    .foregroundStyle(.secondary)
            }

            LabeledContent("Format") {
                Text("GeoJSON + Gzip")
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("Dataset")
        } footer: {
            Text("Historical border data is currently shipped with the app. There is no external sync or download configuration yet.")
        }
    }

    private var loadingSection: some View {
        Section {
            LabeledContent("Caching") {
                Text("Automatic")
                    .foregroundStyle(.secondary)
            }

            LabeledContent("Year Index") {
                Text("Cached In Memory")
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("Loading")
        } footer: {
            Text("Data loading and caching are managed automatically. When real data preferences exist, they should be added here instead of using placeholder controls.")
        }
    }
}

#if DEBUG
struct DataSettingsScene_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DataSettingsScene()
        }
    }
}
#endif
