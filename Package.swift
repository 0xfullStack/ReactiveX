// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ReactiveX",
    platforms: [
        .iOS(.v13), .macOS(.v12), .tvOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "ReactiveX",
            targets: ["ReactiveX"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "6.5.0"),
        .package(url: "https://github.com/Moya/Moya.git", from: "15.0.0"),
        .package(url: "https://github.com/daltoniam/Starscream.git", from: "4.0.0"),
        .package(url: "https://github.com/socketio/socket.io-client-swift", revision: "a1ed825835a2d8c2555938e96557ccc05e4bebf3"),
        .package(url: "https://github.com/Modularize-Packages/Reachability.git", branch: "main"),
        .package(url: "https://github.com/Modularize-Packages/Serialization.git", branch: "main")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ReactiveX",
            dependencies: [
                .byName(name: "RxSwift"),
                .product(name: "RxCocoa", package: "RxSwift"),
                .byName(name: "Moya"),
                .product(name: "RxMoya", package: "Moya"),
                .byName(name: "Starscream"),
                .product(name: "SocketIO", package: "socket.io-client-swift"),
                .byName(name: "Reachability"),
                .byName(name: "Serialization")
            ]),
        .testTarget(
            name: "ReactiveXTests",
            dependencies: ["ReactiveX"]),
    ]
)
