# RGB Lib Swift bindings

This project builds a Swift library, `RgbLib`, for the [rgb-lib]
Rust library, which is included as a git submodule. The bindings are created by
the [rgb-lib-uniffi] project, which is located inside the rgb-lib submodule.

## Usage

To use the Swift language bindings in your Xcode iOS or MacOS project add
its GitHub repository (https://github.com/RGB-Tools/rgb-lib-swift) and select
one of the release versions.
Then link the C++ library by going to
`Build Phases -> Link Binary With Libraries -> Add items (+)` and adding
`libc++.tbd`.
You may then import and use the `RgbLib` library in your Swift code.

## Build and publish

If you are a maintainer of this project or want to build and publish this
project to your own Github repository use the following steps:

```shell
# Update the submodule
git submodule update --init

# Generate the bindings and FFI ZIP
./generate.sh
```

Then update the `Package.swift` file with the new expected URL for the ZIP
file and new checksum as shown at the end of the `generate.sh` script.
For example:
```swift
.binaryTarget(
   name: "rgb_libFFI",
   url: "https://github.com/RGB-Tools/rgb-lib-swift/releases/download/0.3.0-beta.4/rgb_libFFI.xcframework.zip",
   checksum: "51557d776de1c1c7d31687b1a54b75a194cfbaee567ee9f1c62f6363b5fb97cc"),
```

Commit the changed `Package.swift` file, then tag the commit with the new
version number.

Finally, create a GitHub release for your new tag and upload the newly created
ZIP to the new GitHub release and publish the release.

Now you can test the new package in Xcode.
If you get an error you might need to reset the Xcode package caches:
`File -> Packages -> Reset Package Caches`.


[rgb-lib]: https://github.com/RGB-Tools/rgb-lib
[rgb-lib-uniffi]: https://github.com/RGB-Tools/rgb-lib/tree/master/bindings/uniffi

## BFA releases

The separate `BFA Apple Release` workflow builds **rgb-lib-bfa** using an explicit
40-character source SHA. The ordinary rgb-lib workflow remains separate.
A source release `v0.3.0-beta.7` produces BFA version `0.3.0-beta.7-bfa`.
Use exactly the same version and source SHA as the Android BFA release.

### Test and publish

1. Merge the workflow into the repository's default branch to receive
   `repository_dispatch` events. A manual run can select a feature branch after
   GitHub has registered the workflow.
2. Add `BFA_SOURCE_READ_TOKEN`, with read-only Contents access to the private
   `UTEXO-Protocol/rgb-lib-bfa` repository.
3. Run `BFA Apple Release` with `version`, `source_sha`, and `publish=false`
   (default). Inspect the build artifact and test integration before publishing.
4. Run with `publish=true`, or enable automatic dispatch in rgb-lib-bfa after
   both platforms pass. This repository must be **public**. `GITHUB_TOKEN`
   requires Contents write permission for the publish job.

The build pins Rust 1.94.1, uses the committed Cargo lockfile, builds release
binaries, and compiles/links the generated Swift wrapper against all five target
architectures. Supported platforms: iOS 16+ arm64, iOS Simulator arm64/x86_64,
and macOS 12+ arm64/x86_64. Version metadata records the Xcode version used.

The GitHub Release contains:

- `rgb_libFFI.xcframework.zip`: native binary distribution used by SPM.
- `rgb-lib-bfa-swift-<version>.zip`: XCFramework **plus**
  `Sources/RgbLib/RgbLib.swift`, `Package.swift`, license, and `version.json`.
- `version.json`: source SHA, source/package versions, build targets and tools.
- `SHA256SUMS`: SHA-256 hashes of all other release assets.

The tagged release commit contains the matching generated Swift source and SPM
manifest. It does not update the default branch's ordinary rgb-lib manifest and
does not commit private Rust source or change the tracked submodule.
For SPM, use this repository and the **exact** BFA version, e.g.
`0.3.0-beta.7-bfa` (an example, not a pre-existing release).

### CocoaPods / rgb-sdk-rn

For React Native integration, download the complete Swift archive, verify its
checksum, and vendor both `rgb_libFFI.xcframework` and `RgbLib.swift` into the SDK.
Include the Swift file in the pod's `source_files`, the XCFramework in
`vendored_frameworks`, `c++` and `sqlite3` in `libraries`, and `Security` and
`SystemConfiguration` in `frameworks`. Set the iOS deployment target to at least
16.0. Do not simultaneously link the ordinary rgb-lib variant. Adapt the SDK's
Swift wrapper to the BFA API separately; publishing this package does not migrate
the existing RGBLightningNode integration.

Download all release assets into one directory and run
`shasum -a 256 --check SHA256SUMS`. Compare `source_commit` in `version.json`
with the Android release. Public download is checked anonymously by the workflow.

Existing tags are never overwritten. If publication fails after the release tag
is pushed, recover the GitHub Release using the retained build artifact and that
tag; do not move the tag. Build artifacts are retained for 14 days. For a new
source commit use a new version on both platforms.
