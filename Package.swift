// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "RgbLib",
    platforms: [
        .macOS(.v12),
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "RgbLib",
            targets: ["rgb_libFFI", "RgbLib"]),
    ],
    dependencies: [],
    targets: [
        .binaryTarget(
           name: "rgb_libFFI",
           url: "https://github.com/UTEXO-Protocol/rgb-lib-swift/releases/download/0.3.0-beta.15/rgb_libFFI.xcframework.zip",
           checksum: "26ea0d90e93c3157b9d13f6c6f54ddfbdd7f4587111aa65b19b277119f5b1e12"),
        .target(
            name: "RgbLib",
            dependencies: ["rgb_libFFI"]),
    ]
)
