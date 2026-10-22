import hashlib
import os
from pathlib import Path
import plistlib
import subprocess
import sys
import tempfile
import unittest
import zipfile

SCRIPT = Path(__file__).with_name('package_bfa.py')
VERSION = '0.3.0-beta.7-bfa'


class ApplePackageTests(unittest.TestCase):
    def package(self, root, missing_simulator=False):
        framework = root / 'bfa-build/rgb_libFFI.xcframework'
        framework.mkdir(parents=True)
        entries = []
        for name, platform, variant, architectures in [
            ('ios-arm64', 'ios', '', ['arm64']),
            ('ios-arm64_x86_64-simulator', 'ios', 'simulator', ['arm64', 'x86_64']),
            ('macos-arm64_x86_64', 'macos', '', ['arm64', 'x86_64']),
        ]:
            if missing_simulator and variant == 'simulator':
                continue
            entry = dict(LibraryIdentifier=name, LibraryPath='librgblibuniffi.a', SupportedPlatform=platform, SupportedArchitectures=architectures)
            if variant:
                entry['SupportedPlatformVariant'] = variant
            entries.append(entry)
            (framework / name).mkdir()
            (framework / name / 'librgblibuniffi.a').write_bytes(b'binary')
        (framework / 'Info.plist').write_bytes(plistlib.dumps(dict(AvailableLibraries=entries)))
        for prefix in ('bfa-build/', ''):
            sources = root / prefix / 'Sources/RgbLib'
            sources.mkdir(parents=True)
            (sources / 'RgbLib.swift').write_text('import rgb_libFFI\n')
        (root / 'bfa-build/version.json').write_text('{}\n')
        (root / 'LICENSE').write_text('MIT\n')
        private = root / 'rgb-lib/src'
        private.mkdir(parents=True)
        (private / 'private.rs').write_text('PRIVATE SOURCE MUST NOT BE PACKAGED')
        return subprocess.run([sys.executable, str(SCRIPT)], cwd=root,
                              env={**os.environ, 'RELEASE_VERSION': VERSION, 'GITHUB_REPOSITORY': 'UTEXO-Protocol/rgb-lib-swift'},
                              capture_output=True, text=True)

    def test_complete_distribution_and_matching_spm_checksum(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            result = self.package(root)
            self.assertEqual(result.returncode, 0, result.stderr)
            binary = root / 'release-assets/rgb_libFFI.xcframework.zip'
            manifest = (root / 'Package.swift').read_text()
            self.assertIn(hashlib.sha256(binary.read_bytes()).hexdigest(), manifest)
            self.assertIn(f'/releases/download/{VERSION}/', manifest)
            with zipfile.ZipFile(root / f'release-assets/rgb-lib-bfa-swift-{VERSION}.zip') as archive:
                names = archive.namelist()
                self.assertIn('Sources/RgbLib/RgbLib.swift', names)
                self.assertIn('rgb_libFFI.xcframework/Info.plist', names)
                self.assertIn('version.json', names)
                self.assertIn('Package.swift', names)
                self.assertFalse(any('private.rs' in name or name.startswith('rgb-lib/') for name in names))

    def test_missing_simulator_slice_fails(self):
        with tempfile.TemporaryDirectory() as directory:
            self.assertNotEqual(self.package(Path(directory), missing_simulator=True).returncode, 0)


if __name__ == '__main__':
    unittest.main()
