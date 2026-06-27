// swift-tools-version: 6.3.1

import PackageDescription

let package = Package(
    name: "swift-decimal-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        .library(name: "Decimal Primitives", targets: ["Decimal Primitives"]),
        .library(
            name: "Decimal Primitives Test Support",
            targets: ["Decimal Primitives Test Support"]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Decimal Primitives",
            dependencies: [
            ],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("InternalImportsByDefault"),
                .enableUpcomingFeature("MemberImportVisibility"),
                .strictMemorySafety()
            ]
        ),
        .target(
            name: "Decimal Primitives Test Support",
            dependencies: [
                "Decimal Primitives",
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
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
