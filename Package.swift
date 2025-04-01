// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "NSLogging",
    platforms: [.macOS(.v14)],
    products: [
        .library(
            name: "NSLogging",
            targets: ["NSLogging"]
        ),
        .library(
            name: "Module",
            type: .dynamic,
            targets: ["NSLogging"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/kabiroberai/node-swift.git", from: "1.3.0"),
    ],
    targets: [
        .target(
            name: "NSLogging",
            dependencies: [
                .product(name: "NodeAPI", package: "node-swift"),
                .product(name: "NodeModuleSupport", package: "node-swift"),
            ]
        )
    ]
)
