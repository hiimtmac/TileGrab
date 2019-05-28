// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TileGrab",
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/console.git", from: "3.1.0"),
        .package(url: "https://github.com/apple/swift-package-manager.git", .branch("swift-5.0-branch")),
        .package(url: "https://github.com/drmohundro/SWXMLHash.git", from: "4.9.0")
    ],
    targets: [
        .target(
            name: "TileGrab",
            dependencies: ["TileGrabCore"]),
        .target(
            name: "TileGrabCore",
            dependencies: ["GRDB", "Console", "SPMUtility","SWXMLHash"]),
    ]
)
