// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "siteify",
    platforms: [.macOS("10.11")],
    products: [
        .executable(name: "siteify", targets: ["siteify"]),
    ],
    dependencies: [
        .package(url: "https://github.com/johnno1962/SourceKit.git", .branch("master")),
        .package(url: "https://github.com/johnno1962/SwiftLSPClient.git", .branch("master")),
    ],
    targets: [
        .target(name: "siteify", dependencies: ["SwiftLSPClient"], path: "siteify/"),
    ]
)