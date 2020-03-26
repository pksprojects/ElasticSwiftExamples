// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ElasticSwiftKitura",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/IBM-Swift/Kitura", from: "2.7.1"),
        .package(url: "https://github.com/IBM-Swift/Kitura-OpenAPI.git", from: "1.2.1"),
        .package(url: "https://github.com/IBM-Swift/HeliumLogger.git", from: "1.8.1"),
        .package(url: "https://github.com/pksprojects/ElasticSwift.git", from: "1.0.0-alpha.10")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(name: "ElasticSwiftKitura", dependencies: [ .target(name: "Application"), "Kitura", "HeliumLogger"]),
        .target(name: "Application", dependencies: [ "Kitura", "KituraOpenAPI", "ElasticSwift", "ElasticSwiftCore", "ElasticSwiftCodableUtils", "ElasticSwiftQueryDSL", "ElasticSwiftNetworking", "HeliumLogger"]),
        
        .testTarget(
            name: "ApplicationTests", dependencies: [.target(name: "Application"), "Kitura" ]),
    ]
)
