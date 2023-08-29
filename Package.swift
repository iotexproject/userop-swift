// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "userop-swift",
    platforms: [
        .macOS(.v11), .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "userop-swift",
            targets: ["userop-swift"]),
    ],
    dependencies: [
        .package(url: "https://github.com/attaswift/BigInt.git", from:  "5.3.0"),
        .package(url: "https://github.com/zhangliugang/web3swift.git", .branch("userop"))
//        .package(path: "../../web3swift")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "userop-swift", dependencies: ["BigInt", "web3swift"]),
        .testTarget(
            name: "userop-swiftTests",
            dependencies: ["userop-swift"]),
    ]
)
