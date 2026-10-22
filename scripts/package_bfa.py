#!/usr/bin/env python3
"""Package the binary and generated Swift sources without private Rust source."""
import hashlib
import os
from pathlib import Path
import plistlib
import shutil
import zipfile

version = os.environ["RELEASE_VERSION"]
repository = os.environ["GITHUB_REPOSITORY"]
build = Path("bfa-build")
framework = build / "rgb_libFFI.xcframework"
with (framework / "Info.plist").open("rb") as stream:
    libraries = plistlib.load(stream)["AvailableLibraries"]
actual = {(entry["SupportedPlatform"], entry.get("SupportedPlatformVariant", ""), tuple(sorted(entry["SupportedArchitectures"]))) for entry in libraries}
assert actual == {("ios", "", ("arm64",)), ("ios", "simulator", ("arm64", "x86_64")), ("macos", "", ("arm64", "x86_64"))}
for entry in libraries:
    assert (framework / entry["LibraryIdentifier"] / entry["LibraryPath"]).stat().st_size > 0

assets = Path("release-assets")
assets.mkdir(exist_ok=True)


def archive(path, entries):
    with zipfile.ZipFile(path, "w", zipfile.ZIP_DEFLATED) as output:
        for entry in entries:
            files = sorted(entry.rglob("*")) if entry.is_dir() else [entry]
            for file in files:
                if file.is_file():
                    output.write(file, file.relative_to(build))


binary = assets / "rgb_libFFI.xcframework.zip"
archive(binary, [framework])
checksum = hashlib.sha256(binary.read_bytes()).hexdigest()
manifest = f'''// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "RgbLib",
    platforms: [.macOS(.v12), .iOS(.v16)],
    products: [.library(name: "RgbLib", targets: ["RgbLib"])],
    targets: [
        .binaryTarget(
            name: "rgb_libFFI",
            url: "https://github.com/{repository}/releases/download/{version}/rgb_libFFI.xcframework.zip",
            checksum: "{checksum}"),
        .target(name: "RgbLib", dependencies: ["rgb_libFFI"],
                linkerSettings: [.linkedLibrary("c++"), .linkedLibrary("sqlite3"),
                                 .linkedFramework("Security"), .linkedFramework("SystemConfiguration")])
    ]
)
'''
(build / "Package.swift").write_text(manifest)
shutil.copyfile("LICENSE", build / "LICENSE")
shutil.copyfile(build / "version.json", assets / "version.json")
archive(assets / f"rgb-lib-bfa-swift-{version}.zip", [framework, build / "Sources", build / "Package.swift", build / "LICENSE", build / "version.json"])
# SPM release commit contains only public bindings and the binary manifest.
Path("Package.swift").write_text(manifest)
shutil.copyfile(build / "Sources/RgbLib/RgbLib.swift", "Sources/RgbLib/RgbLib.swift")
shutil.copyfile(build / "version.json", "bfa-version.json")
