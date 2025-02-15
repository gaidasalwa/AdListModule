// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AdListModule",
    platforms: [
        .iOS(.v15) // ✅ Spécifie que le module supporte iOS 13 minimum
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AdListModule",
            targets: ["AdListModule"]),
    ],
    dependencies: [
        .package(url: "https://github.com/gaidasalwa/CoreModule.git", from: "1.0.0"),
        .package(url: "https://github.com/gaidasalwa/AppDI.git", from: "1.0.0"),
        .package(url: "https://github.com/gaidasalwa/AppCoordinatorModule.git", from: "1.1.0"),
        .package(url: "https://github.com/gaidasalwa/AdDetailsModule.git", from: "1.1.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AdListModule",
            dependencies: ["CoreModule", "AppDI", "AppCoordinatorModule", "AdDetailsModule"]),
        .testTarget(
            name: "AdListModuleTests",
            dependencies: ["AdListModule"]
        ),
    ]
)
