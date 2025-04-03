// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "NodeSwiftLogging",
    platforms: [.macOS(.v14)],
    products: [
        .library(
            name: "NodeSwiftLogging",
            targets: ["NodeSwiftLogging"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/kabiroberai/node-swift.git", from: "1.3.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "NodeSwiftLogging",
            dependencies: [
                .product(name: "NodeAPI", package: "node-swift"),
                .product(name: "Logging", package: "swift-log"),
            ]
        )
    ]
)
