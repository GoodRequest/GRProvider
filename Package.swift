// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GRProvider",
    platforms: [.iOS(.v11)],
    products: [
        .library(
            name: "GRProvider",
            targets: ["GRProvider"]),
    ],
    dependencies: [
        .package(url: "https://github.com/onmyway133/DeepDiff.git", .upToNextMajor(from: "2.3.0"))

    ],
    targets: [
        .target(
            name: "GRProvider",
            dependencies: ["DeepDiff"],
            path: "Sources"),
        .testTarget(
            name: "GRProviderTests",
            dependencies: ["GRProvider"]),
    ]
)
