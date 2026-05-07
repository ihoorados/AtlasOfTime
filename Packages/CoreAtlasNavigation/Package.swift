// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "CoreAtlasNavigation",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "CoreAtlasNavigation",
            targets: ["CoreAtlasNavigation"]
        )
    ],
    targets: [
        .target(
            name: "CoreAtlasNavigation"
        ),
        .testTarget(
            name: "CoreAtlasNavigationTests",
            dependencies: ["CoreAtlasNavigation"]
        )
    ]
)
