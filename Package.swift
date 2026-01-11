// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-decimal-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(name: "Decimal Primitives", targets: ["Decimal Primitives"])
    ],
    dependencies: [
        .package(path: "../swift-test-primitives")
    ],
    targets: [
        .target(
            name: "Decimal Primitives",
            dependencies: [],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("InternalImportsByDefault"),
                .enableUpcomingFeature("MemberImportVisibility")
            ]
        ),
        .testTarget(
            name: "Decimal Primitives Tests",
            dependencies: [
                "Decimal Primitives",
                .product(name: "Test Primitives", package: "swift-test-primitives")
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
