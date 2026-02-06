// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppStoreVersionKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AppStoreVersionKit",
            targets: ["AppStoreVersionKit"]
        ),
    ],
    targets: [
        .target(
            name: "AppStoreVersionKit"
        ),
        .testTarget(
            name: "AppStoreVersionKitTests",
            dependencies: ["AppStoreVersionKit"]
        ),
    ]
)
