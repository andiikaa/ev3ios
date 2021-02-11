// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "EV3SDK",
    platforms: [
        .macOS(.v10_13),
        .iOS(.v8)
    ],
    products: [
        .library(name: "EV3SDK", targets: ["EV3SDK"])
    ],
    targets: [
        .target(name: "EV3SDK", path: "EV3IOS")
    ]
)
