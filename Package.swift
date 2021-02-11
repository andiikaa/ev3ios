// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "EV3SDK",
    products: [
        .library(name: "EV3SDK", targets: ["EV3SDK"])
    ],
    targets: [
        .target(name: "EV3SDK", path: "EV3IOS")
    ]
)
