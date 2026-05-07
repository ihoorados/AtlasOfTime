// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "CoreAtlasAI",
    platforms: [
        .iOS(.v26),
        .macOS(.v26)
    ],
    products: [
        .library(
            name: "CoreAtlasAI",
            targets: ["CoreAtlasAI"]
        )
    ],
    dependencies: [
        .package(path: "../CoreAtlasDomain")
    ],
    targets: [
        .target(
            name: "CoreAtlasAI",
            dependencies: [
                .product(name: "CoreAtlasDomain", package: "CoreAtlasDomain")
            ]
        ),
        .testTarget(
            name: "CoreAtlasAITests",
            dependencies: ["CoreAtlasAI"]
        )
    ]
)
