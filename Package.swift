// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TileGrab",
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "3.5.0"),
        .package(url: "https://github.com/vapor/console.git", from: "3.0.0")
    ],
    targets: [
        .target(
            name: "TileGrab",
            dependencies: ["TileGrabCore"]),
        .target(
            name: "TileGrabCore",
            dependencies: ["GRDB", "Console"]),
    ]
)
