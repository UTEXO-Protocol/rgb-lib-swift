// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "RgbLib",
    platforms: [.macOS(.v12), .iOS(.v16)],
    products: [.library(name: "RgbLib", targets: ["RgbLib"])],
    targets: [
        .binaryTarget(
            name: "rgb_libFFI",
            url: "https://github.com/UTEXO-Protocol/rgb-lib-swift/releases/download/0.3.0-beta.7-upstream-dev-bfa.6-bfa/rgb_libFFI.xcframework.zip",
            checksum: "5fc1a112eb7ddf148402639d4948ae167ac69cd420b620d34b8b1278e6600763"),
        .target(name: "RgbLib", dependencies: ["rgb_libFFI"],
                linkerSettings: [.linkedLibrary("c++"), .linkedLibrary("sqlite3"),
                                 .linkedFramework("Security"), .linkedFramework("SystemConfiguration")])
    ]
)
