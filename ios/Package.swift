// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AppVersionManager",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "AppVersionManager",
            targets: ["AppVersionManager"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "6.0.0")
    ],
    targets: [
        .target(
            name: "AppVersionManager",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm")
            ],
            path: "Sources" // 👈 Укажите путь к папке с исходниками
        )
    ]
)