// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "NSUtils",
    platforms: [.macOS(.v14)],
    products: [
        .library(
            name: "NSUtils",
            targets: ["NSUtils"]
        ),
        .library(
            name: "Module",
            type: .dynamic,
            targets: ["NSUtils"]
        )
    ],
    dependencies: [
        .package(path: "node_modules/node-swift"),
    ],
    targets: [
        .target(
            name: "NSUtils",
            dependencies: [
                .product(name: "NodeAPI", package: "node-swift"),
                .product(name: "NodeModuleSupport", package: "node-swift"),
            ]
        ),
        .testTarget(
            name: "NSUtilsTests",
            dependencies: [
                .product(name: "NodeAPI", package: "node-swift"),
                .product(name: "NodeModuleSupport", package: "node-swift"),
            ]
        ),
    ]
)
