// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "CoreAtlasMap",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "CoreAtlasMap",
            targets: ["CoreAtlasMap"]
        )
    ],
    targets: [
        .target(
            name: "CoreAtlasMap"
        ),
        .testTarget(
            name: "CoreAtlasMapTests",
            dependencies: ["CoreAtlasMap"]
        )
    ]
)
