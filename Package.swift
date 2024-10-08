// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Dripper",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "Dripper",
            targets: ["Dripper"]
        ),
    ],
    targets: [
        .target(
            name: "Dripper"
        ),
        .testTarget(
            name: "DripperTests",
            dependencies: [
                .target(name: "Dripper"),
            ]
        ),

    ],
    swiftLanguageModes: [.v6]
)
