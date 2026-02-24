import Foundation

@MainActor
protocol AtlasDIProviding {
    func makeAtlasViewModel() -> AtlasViewModel
}

