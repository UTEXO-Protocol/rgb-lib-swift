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
           url: "https://github.com/UTEXO-Protocol/rgb-lib-swift/releases/download/0.3.0-beta.11/rgb_libFFI.xcframework.zip",
           checksum: "2c5c099520f6859cb3f2eff80886b953df2e42b57271aa09edd5565a374d8231"),
        .target(
            name: "RgbLib",
            dependencies: ["rgb_libFFI"]),
    ]
)
