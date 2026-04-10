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
           url: "https://github.com/UTEXO-Protocol/rgb-lib-swift/releases/download/0.3.0-beta.17/rgb_libFFI.xcframework.zip",
           checksum: "db8e2de6fb8e309ca04a9379f15ceaa09e60f9469ad442ccc54e763609bcfeeb"),
        .target(
            name: "RgbLib",
            dependencies: ["rgb_libFFI"]),
    ]
)
