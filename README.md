# qt-static-build

This repository hosts static builds of Qt used to build the [CTK AppLauncher](https://github.com/commontk/AppLauncher).

Prebuilt binaries are published as [GitHub release assets](../../releases) and organized by platform and Qt version.
The table below lists the available builds, organized by Qt version and target platform.

Each release contains:

- One or more archive files containing the Qt build for a given platform and version
- Notes in the release description specifying:
  - How to extract the archive (e.g., `tar`, `7zip`)
  - Whether the build is relocatable or must be extracted to a specific path
  - Build instructions or a reference to the script used to generate the archive

## Available Qt Builds

|        | Linux                                             | macOS                                           | Windows                                   |
| ------ | ------------------------------------------------- | ----------------------------------------------- | ----------------------------------------- |
| 4.7.4  |                                                   | [4.7.4-macosx-10.6-g++][4.7.4-m]                |                                           |
| 4.8.6  | [4.8.6-centos-5.5][4.8.6-l] (GLIBC 2.5)           |                                                 | [4.8.6-vs2008][4.8.6-w]                   |
| 5.11.2 |                                                   |                                                 | [5.11.2-static-ltcg-msvc2017-x86][5.11.2] |
| 5.15.2 | [qt-5.15.2-manylinux2.28-static-x86_64][5.15.2-l] | [qt-5.15.2-macosx10.13-static-x86_64][5.15.2-m] |                                           |
| 6.12.0 | [manylinux_2_28-x86_64, arm64][6.12.0]            | [macos-x86_64, arm64][6.12.0]                   | [windows-msvc2022-x86_64, arm64][6.12.0]  |

[4.7.4-m]: https://github.com/jcfr/qt-static-build/releases/tag/4.7.4-macosx-10.6-g%2B%2B
[4.8.6-l]: https://github.com/jcfr/qt-static-build/releases/tag/4.8.6-centos-5.5
[4.8.6-w]: https://github.com/jcfr/qt-static-build/releases/tag/4.8.6-vs2008
[5.11.2]: https://github.com/jcfr/qt-static-build/releases/tag/applauncher-5.11.2-vs2017
[5.15.2-l]: https://github.com/jcfr/qt-static-build/releases/tag/qt-5.15.2-manylinux2.28-static-x86_64
[5.15.2-m]: https://github.com/jcfr/qt-static-build/releases/tag/qt-5.15.2-macosx10.13-static-x86_64
[6.12.0]: ../../releases/tag/qt-6.12.0-static

## Building Qt6

The [Build Qt6](.github/workflows/build-qt6.yml) GitHub Actions workflow builds a static `qtbase`
(providing `Core`, `Gui`, `Widgets`, `Test`, ...) for these targets:

| Platform | x86_64 runner    | arm64 runner       | Toolchain                                        |
| -------- | ---------------- | ------------------ | ------------------------------------------------ |
| Windows  | `windows-2022`   | `windows-11-arm`   | Visual Studio 2022, static runtime (`/MT`)       |
| Linux    | `ubuntu-24.04`   | `ubuntu-24.04-arm` | `manylinux_2_28` container (glibc 2.28), xcb QPA |
| macOS    | `macos-15-intel` | `macos-15`         | Xcode, Qt default deployment target              |

To build a new Qt version, run the workflow manually (_Actions_ > _Build Qt6_ > _Run workflow_),
enter the Qt version, and check _Publish_ to create a `qt-<version>-static` release holding all
six archives and their SHA256 checksums.

The same scripts can be run locally:

- Linux, macOS: `scripts/build-qt6.sh <qt-version> <name> <output-dir> [extra configure args...]`
  (on Linux, run `scripts/install-linux-deps.sh` first in a `manylinux_2_28` container)
- Windows, from an MSVC developer prompt: `scripts/build-qt6.ps1 -QtVersion <qt-version> -Name <name> -OutputDir <output-dir>`
