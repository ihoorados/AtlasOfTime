import Foundation
import CoreAtlasData

struct BundleDataSource {
    private let bundle: Bundle
    private let searchSubdirectories: [String?]

    init(bundle: Bundle = .main, baseSubdirectory: String = "Resources/AtlasOfTimeData") {
        self.bundle = bundle
        var candidates: [String?] = []

        func appendUnique(_ candidate: String?) {
            let normalized = candidate?
                .trimmingCharacters(in: CharacterSet(charactersIn: "/"))
            if !candidates.contains(where: { $0 == normalized }) {
                candidates.append(normalized)
            }
        }

        appendUnique(baseSubdirectory)
        appendUnique("AtlasOfTimeData")
        appendUnique("Resources/AtlasOfTimeData")
        appendUnique("Resource/AtlasOfTimeData")
        appendUnique(nil) // Bundle root

        self.searchSubdirectories = candidates
    }

    func readIndexJSON() throws -> Data {
        guard let url = resourceURL(relativePath: "index.json") else {
            throw CoreAtlasData.AtlasDataError.resourceNotFound("index.json (searched AtlasOfTimeData subdirectories and bundle root)")
        }

        return try readData(at: url)
    }

    func readYearFile(relativePath: String) throws -> Data {
        let normalizedPath = relativePath.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard let url = resourceURL(relativePath: normalizedPath) else {
            throw CoreAtlasData.AtlasDataError.resourceNotFound("\(normalizedPath) (searched AtlasOfTimeData subdirectories and bundle root)")
        }

        return try readData(at: url)
    }

    private func resourceURL(relativePath: String) -> URL? {
        let normalizedPath = relativePath.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard !normalizedPath.isEmpty else { return nil }

        let fileName = URL(fileURLWithPath: normalizedPath).lastPathComponent
        let stem = URL(fileURLWithPath: normalizedPath).deletingPathExtension().lastPathComponent
        let ext = URL(fileURLWithPath: normalizedPath).pathExtension

        var resourceCandidates = [normalizedPath]
        if fileName != normalizedPath {
            resourceCandidates.append(fileName) // fallback if Xcode flattened folder structure
        }

        for subdirectory in searchSubdirectories {
            for candidate in resourceCandidates {
                if let url = bundle.url(forResource: candidate, withExtension: nil, subdirectory: subdirectory) {
                    return url
                }
            }

            if !ext.isEmpty {
                if let url = bundle.url(forResource: stem, withExtension: ext, subdirectory: subdirectory) {
                    return url
                }
            }
        }

        return nil
    }

    private func readData(at url: URL) throws -> Data {
        do {
            return try Data(contentsOf: url, options: .mappedIfSafe)
        } catch {
            throw CoreAtlasData.AtlasDataError.fileReadFailed(url.path)
        }
    }
}

extension BundleDataSource: CoreAtlasData.IndexJSONReading, CoreAtlasData.YearFileReading {}
