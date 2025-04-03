// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "NodeSwiftLoggingExample",
    platforms: [.macOS(.v14)],
    products: [
        .library(
            name: "NodeSwiftLoggingExample",
            targets: ["NodeSwiftLoggingExample"]
        ),
        .library(
            name: "Module",
            type: .dynamic,
            targets: ["NodeSwiftLoggingExample"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/kabiroberai/node-swift.git", from: "1.3.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(name: "NodeSwiftLogging", path: ".."),   // <- For development convenience here, but perhaps better to use...
        // .package(url: "https://github.com/stevengharris/NodeSwiftLogging.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "NodeSwiftLoggingExample",
            dependencies: [
                .product(name: "NodeAPI", package: "node-swift"),
                .product(name: "NodeModuleSupport", package: "node-swift"),
                .product(name: "Logging", package: "swift-log"),
                "NodeSwiftLogging"
            ]
        )
    ]
)
