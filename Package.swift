// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "RgbLib",
    platforms: [.macOS(.v12), .iOS(.v16)],
    products: [.library(name: "RgbLib", targets: ["RgbLib"])],
    targets: [
        .binaryTarget(
            name: "rgb_libFFI",
            url: "https://github.com/UTEXO-Protocol/rgb-lib-swift/releases/download/0.3.0-beta.7-upstream-dev-bfa.8-bfa/rgb_libFFI.xcframework.zip",
            checksum: "56edde5c9207548fabbe5944fa8ff81c2b3740c9d85d60f4f63027be969d234a"),
        .target(name: "RgbLib", dependencies: ["rgb_libFFI"],
                linkerSettings: [.linkedLibrary("c++"), .linkedLibrary("sqlite3"),
                                 .linkedFramework("Security"), .linkedFramework("SystemConfiguration")])
    ]
)
