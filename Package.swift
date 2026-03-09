// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "EverMemOSKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],
    products: [
        .library(name: "EverMemOSKit", targets: ["EverMemOSKit"]),
    ],
    targets: [
        .target(
            name: "EverMemOSKit",
            path: "Sources/EverMemOSKit"
        ),
        .testTarget(
            name: "EverMemOSKitTests",
            dependencies: ["EverMemOSKit"],
            path: "Tests/EverMemOSKitTests"
        ),
    ]
)
