// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CircleDriver",
    products: [
        .library(name: "JustGoTowardsCircleDriver", targets: ["JustGoTowardsCircleDriver"]),
        .library(name: "CircleDriver", targets: ["CircleDriver"]),
        .library(name: "RaceTrack", targets: ["RaceTrack"]),
        .executable(name: "racetrack", targets: ["Main"])
    ],
    dependencies: [
        .package(url: "https://github.com/jakeheis/SwiftCLI", from: "6.0.0"),
        .package(url: "https://github.com/JohnSundell/Files", from: "4.0.0"),
        .package(url: "https://github.com/onevcat/Rainbow", from: "3.0.0")
    ],
    targets: [
        .target(
            name: "Main",
            dependencies: ["RaceTrack"]
        ),
        .target(
            name: "CircleDriver",
            dependencies: []
        ),
        .testTarget(
            name: "CircleDriverTests",
            dependencies: ["CircleDriver"]
        ),
        .target(
            name: "JustGoTowardsCircleDriver",
            dependencies: ["CircleDriver"]
        ),
        .target(
            name: "RaceTrack",
            dependencies: ["CircleDriver", "JustGoTowardsCircleDriver", "SwiftCLI", "Files", "Rainbow"]
        ),
        .testTarget(
            name: "RaceTrackTests",
            dependencies: ["RaceTrack"]
        ),
    ]
)
