// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "RgbLib",
    platforms: [.macOS(.v12), .iOS(.v16)],
    products: [.library(name: "RgbLib", targets: ["RgbLib"])],
    targets: [
        .binaryTarget(
            name: "rgb_libFFI",
            url: "https://github.com/UTEXO-Protocol/rgb-lib-swift/releases/download/0.3.0-beta.7-upstream-dev-bfa.5-bfa/rgb_libFFI.xcframework.zip",
            checksum: "8feb29e02dcdc363973bf34579d77ea41371de6c8b4847045990a683d4fffdd9"),
        .target(name: "RgbLib", dependencies: ["rgb_libFFI"],
                linkerSettings: [.linkedLibrary("c++"), .linkedLibrary("sqlite3"),
                                 .linkedFramework("Security"), .linkedFramework("SystemConfiguration")])
    ]
)
