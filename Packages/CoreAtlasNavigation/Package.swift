// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "CoreAtlasNavigation",
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
