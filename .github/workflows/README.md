# Workflows

## release.yml — Build and Release

Builds XCFramework and publishes a GitHub Release with Swift Package Manager support.

- **Trigger**: automatically via `repository_dispatch` from `rgb-lib`, or manually
- **Input**: `version` (e.g. `0.3.0-beta.5`, no `v` prefix)
- **What it does**:
  1. Checks out `utexo-master` with submodules
  2. Runs `generate.sh` to build bindings and XCFramework for all Apple targets
  3. Computes checksum and updates `Package.swift` with the release URL
  4. Commits, tags, and pushes
  5. Creates a GitHub Release with the `rgb_libFFI.xcframework.zip`

## test.yml — Test Library (local)

Tests the Swift bindings using **local** (freshly built) XCFramework.

- **Trigger**: push to `utexo-master`, PRs to `utexo-master`, after release workflow, or manually
- **What it does**:
  1. Runs `generate.sh` to build bindings and XCFramework from source
  2. Overrides `Package.swift` to use the local `.xcframework` path
  3. Builds and runs `Tests/` on macOS and iOS Simulator

## test_tag.yml — Test Library (published tag)

Tests the **published** Swift package — simulates what end users do.

- **Trigger**: push of a tag (i.e. right after a release)
- **What it does**:
  1. Checks out the tagged commit (which has the release `Package.swift` pointing to the remote XCFramework URL)
  2. Resolves SPM dependencies (downloads the published XCFramework zip)
  3. Builds and runs `Tests/` on macOS and iOS Simulator