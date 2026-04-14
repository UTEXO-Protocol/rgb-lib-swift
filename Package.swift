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
           url: "https://github.com/UTEXO-Protocol/rgb-lib-swift/releases/download/0.3.0-beta.18/rgb_libFFI.xcframework.zip",
           checksum: "def7821f399eca2a872b526fcc3bb31822b9a44dde633be62721930536d6ff81"),
        .target(
            name: "RgbLib",
            dependencies: ["rgb_libFFI"]),
    ]
)
