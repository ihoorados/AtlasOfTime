// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "CoreAtlasData",
    platforms: [
        .iOS(.v17),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "CoreAtlasData",
            targets: ["CoreAtlasData"]
        )
    ],
    dependencies: [
        .package(path: "../CoreAtlasDomain")
    ],
    targets: [
        .target(
            name: "CoreAtlasData",
            dependencies: [
                .product(name: "CoreAtlasDomain", package: "CoreAtlasDomain")
            ]
        ),
        .testTarget(
            name: "CoreAtlasDataTests",
            dependencies: ["CoreAtlasData"]
        )
    ]
)
