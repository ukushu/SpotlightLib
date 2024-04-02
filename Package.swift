// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SpotlightLib",
    platforms: [.macOS(.v12), .iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SpotlightLib",
            targets: ["SpotlightLib"]),
    ],
    dependencies: [
        .package(url: "https://gitlab.com/sergiy.vynnychenko/essentials.git", branch: "master"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SpotlightLib",
            dependencies: [
                .product(name: "Essentials", package: "essentials")
            ]),
        .testTarget(
            name: "SpotlightLibTests",
            dependencies: [
                "SpotlightLib"
            ])
    ]
    
//    targets: [
//        // Targets are the basic building blocks of a package, defining a module or a test suite.
//        // Targets can depend on other targets in this package and products from dependencies.
//        .target(
//            name: "SpotlightLib"),
//        .testTarget(
//            name: "SpotlightLibTests",
//            dependencies: ["SpotlightLib"]),
//    ]
)
