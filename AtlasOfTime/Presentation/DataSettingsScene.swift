import SwiftUI

struct DataSettingsScene: View {
    var body: some View {
        Form {
            datasetSection
            loadingSection
        }
        .navigationTitle(AppStrings.Settings.Data.title)
    }

    private var datasetSection: some View {
        Section {
            LabeledContent(AppStrings.Settings.Data.source) {
                Text(AppStrings.Settings.Data.bundled)
                    .foregroundStyle(.secondary)
            }

            LabeledContent(AppStrings.Settings.Data.format) {
                Text(AppStrings.Settings.Data.geoJSONGzip)
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text(AppStrings.Settings.Data.datasetTitle)
        } footer: {
            Text(AppStrings.Settings.Data.datasetFooter)
        }
    }

    private var loadingSection: some View {
        Section {
            LabeledContent(AppStrings.Settings.Data.caching) {
                Text(AppStrings.Settings.Data.automatic)
                    .foregroundStyle(.secondary)
            }

            LabeledContent(AppStrings.Settings.Data.yearIndex) {
                Text(AppStrings.Settings.Data.cachedInMemory)
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text(AppStrings.Settings.Data.loadingTitle)
        } footer: {
            Text(AppStrings.Settings.Data.loadingFooter)
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
