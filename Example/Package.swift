// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "NSLoggingExample",
    platforms: [.macOS(.v14)],
    products: [
        .library(
            name: "NSLoggingExample",
            targets: ["NSLoggingExample"]
        ),
        .library(
            name: "Module",
            type: .dynamic,
            targets: ["NSLoggingExample"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/kabiroberai/node-swift.git", from: "1.3.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/stevengharris/NSLogging.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "NSLoggingExample",
            dependencies: [
                .product(name: "NodeAPI", package: "node-swift"),
                .product(name: "NodeModuleSupport", package: "node-swift"),
                .product(name: "Logging", package: "swift-log"),
                "NSLogging"
            ]
        )
    ]
)
