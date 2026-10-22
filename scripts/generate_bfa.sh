#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

manifest=rgb-lib/bindings/uniffi/Cargo.toml
output="$PWD/bfa-build"
# Require a clean output directory so stale slices cannot enter a release.
mkdir "$output"
mkdir -p "$output/headers" "$output/Sources/RgbLib" "$output/ios-simulator" "$output/macos"
export IPHONEOS_DEPLOYMENT_TARGET=16.0
export MACOSX_DEPLOYMENT_TARGET=12.0

cargo run --locked --manifest-path "$manifest" --bin rgb-lib-uniffi-bindgen -- \
  generate rgb-lib/bindings/uniffi/src/rgb-lib.udl --language swift --out-dir "$output/headers"
mv "$output/headers/rgb_lib.swift" "$output/Sources/RgbLib/RgbLib.swift"
mv "$output/headers/rgb_libFFI.modulemap" "$output/headers/module.modulemap"

targets=(aarch64-apple-ios aarch64-apple-ios-sim x86_64-apple-ios aarch64-apple-darwin x86_64-apple-darwin)
for target in "${targets[@]}"; do
  cargo build --locked --release --manifest-path "$manifest" --target "$target"
done
native="$PWD/rgb-lib/bindings/uniffi/target"
lipo -create "$native/aarch64-apple-ios-sim/release/librgblibuniffi.a" \
  "$native/x86_64-apple-ios/release/librgblibuniffi.a" -output "$output/ios-simulator/librgblibuniffi.a"
lipo -create "$native/aarch64-apple-darwin/release/librgblibuniffi.a" \
  "$native/x86_64-apple-darwin/release/librgblibuniffi.a" -output "$output/macos/librgblibuniffi.a"
lipo -verify_arch arm64 "$native/aarch64-apple-ios/release/librgblibuniffi.a"
lipo -verify_arch arm64 x86_64 "$output/ios-simulator/librgblibuniffi.a"
lipo -verify_arch arm64 x86_64 "$output/macos/librgblibuniffi.a"

xcodebuild -create-xcframework \
  -library "$native/aarch64-apple-ios/release/librgblibuniffi.a" -headers "$output/headers" \
  -library "$output/ios-simulator/librgblibuniffi.a" -headers "$output/headers" \
  -library "$output/macos/librgblibuniffi.a" -headers "$output/headers" \
  -output "$output/rgb_libFFI.xcframework"

# Compile and link the generated Swift wrapper against every binary slice.
for spec in 'iphoneos arm64-apple-ios16.0 ios-arm64' \
            'iphonesimulator arm64-apple-ios16.0-simulator ios-arm64_x86_64-simulator' \
            'iphonesimulator x86_64-apple-ios16.0-simulator ios-arm64_x86_64-simulator' \
            'macosx arm64-apple-macos12.0 macos-arm64_x86_64' \
            'macosx x86_64-apple-macos12.0 macos-arm64_x86_64'; do
  read -r sdk triple slice <<< "$spec"
  sdk_path="$(xcrun --sdk "$sdk" --show-sdk-path)"
  slice_dir="$output/rgb_libFFI.xcframework/$slice"
  mkdir -p "$output/smoke/$triple"
  xcrun swiftc -parse-as-library -emit-module -emit-library -module-name RgbLib \
    -target "$triple" -sdk "$sdk_path" -I "$slice_dir/Headers" \
    "$output/Sources/RgbLib/RgbLib.swift" "$slice_dir/librgblibuniffi.a" \
    -lc++ -lsqlite3 -framework Security -framework SystemConfiguration \
    -emit-module-path "$output/smoke/$triple/RgbLib.swiftmodule" \
    -o "$output/smoke/$triple/libRgbLib.dylib"
done
