// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "RgbLib",
    platforms: [.macOS(.v12), .iOS(.v16)],
    products: [.library(name: "RgbLib", targets: ["RgbLib"])],
    targets: [
        .binaryTarget(
            name: "rgb_libFFI",
            url: "https://github.com/UTEXO-Protocol/rgb-lib-swift/releases/download/0.3.0-beta.7-upstream-dev-bfa.2-bfa/rgb_libFFI.xcframework.zip",
            checksum: "b5ada1a5d3c6f303d24130b8a7eacb91cb60dd75e20f780be9f828530fdbe9b4"),
        .target(name: "RgbLib", dependencies: ["rgb_libFFI"],
                linkerSettings: [.linkedLibrary("c++"), .linkedLibrary("sqlite3"),
                                 .linkedFramework("Security"), .linkedFramework("SystemConfiguration")])
    ]
)
