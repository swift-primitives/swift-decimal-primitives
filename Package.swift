// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-decimal-primitives",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(name: "Decimal Primitives", targets: ["Decimal Primitives"]),
        .library(
            name: "Decimal Primitives Test Support",
            targets: ["Decimal Primitives Test Support"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Decimal Primitives",
            dependencies: [],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("InternalImportsByDefault"),
                .enableUpcomingFeature("MemberImportVisibility"),
                .strictMemorySafety(),
            ]
        ),
        .target(
            name: "Decimal Primitives Test Support",
            dependencies: [
                "Decimal Primitives"
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Decimal Primitives Tests",
            dependencies: [
                "Decimal Primitives",
                "Decimal Primitives Test Support",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
