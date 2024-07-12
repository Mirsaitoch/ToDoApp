// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FileCachePackage",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "FileCachePackage",
            targets: ["FileCachePackage"])
    ],
    dependencies: [
        .package(url: "https://github.com/CocoaLumberjack/CocoaLumberjack.git", from: "3.8.0")
    ],
    targets: [
        .target(
            name: "FileCachePackage",
            dependencies: [
                .product(name: "CocoaLumberjackSwift", package: "CocoaLumberjack")
            ]),
        .testTarget(
            name: "FileCachePackageTests",
            dependencies: ["FileCachePackage"])
    ]
)
