// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "CoreAtlasDomain",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "CoreAtlasDomain",
            targets: ["CoreAtlasDomain"]
        )
    ],
    targets: [
        .target(
            name: "CoreAtlasDomain"
        ),
        .testTarget(
            name: "CoreAtlasDomainTests",
            dependencies: ["CoreAtlasDomain"]
        )
    ]
)
