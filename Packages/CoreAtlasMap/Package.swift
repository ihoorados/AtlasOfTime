// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "CoreAtlasMap",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "CoreAtlasMap",
            targets: ["CoreAtlasMap"]
        ),
        .library(
            name: "CoreAtlasMapMapKit",
            targets: ["CoreAtlasMapMapKit"]
        )
    ],
    targets: [
        .target(
            name: "CoreAtlasMap"
        ),
        .target(
            name: "CoreAtlasMapMapKit",
            dependencies: ["CoreAtlasMap"]
        ),
        .testTarget(
            name: "CoreAtlasMapTests",
            dependencies: ["CoreAtlasMap"]
        )
    ]
)
