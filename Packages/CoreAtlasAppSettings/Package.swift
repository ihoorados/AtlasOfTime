// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "CoreAtlasAppSettings",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "CoreAtlasAppSettings",
            targets: ["CoreAtlasAppSettings"]
        )
    ],
    targets: [
        .target(
            name: "CoreAtlasAppSettings"
        ),
        .testTarget(
            name: "CoreAtlasAppSettingsTests",
            dependencies: ["CoreAtlasAppSettings"]
        )
    ]
)
