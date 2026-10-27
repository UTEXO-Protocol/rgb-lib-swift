// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "RgbLib",
    platforms: [.macOS(.v12), .iOS(.v16)],
    products: [.library(name: "RgbLib", targets: ["RgbLib"])],
    targets: [
        .binaryTarget(
            name: "rgb_libFFI",
            url: "https://github.com/UTEXO-Protocol/rgb-lib-swift/releases/download/0.3.0-beta.7-upstream-dev-bfa.3-bfa/rgb_libFFI.xcframework.zip",
            checksum: "7cb7e7c237724bc07ce087035b90996a47d6f6e53c250d589df61bf10a65be01"),
        .target(name: "RgbLib", dependencies: ["rgb_libFFI"],
                linkerSettings: [.linkedLibrary("c++"), .linkedLibrary("sqlite3"),
                                 .linkedFramework("Security"), .linkedFramework("SystemConfiguration")])
    ]
)
