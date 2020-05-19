// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DPProvider",
    platforms: [.iOS(.v11)],
    products: [
        .library(
            name: "DPProvider",
            targets: ["DPProvider"]),
    ],
    dependencies: [
        .package(url: "https://github.com/onmyway133/DeepDiff.git", .upToNextMajor(from: "2.3.0"))

    ],
    targets: [
        .target(
            name: "DPProvider",
            dependencies: ["DeepDiff"],
            path: "Sources"),
        .testTarget(
            name: "DPProviderTests",
            dependencies: ["DPProvider"]),
    ]
)
