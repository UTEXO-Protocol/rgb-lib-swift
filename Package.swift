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
           checksum: "e04adf6256b3fd779686e1f7040b1eb243ac1e5b2ad5142c580088c672eb5ec7"),
        .target(
            name: "RgbLib",
            dependencies: ["rgb_libFFI"]),
    ]
)
