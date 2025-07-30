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

|        | Linux                                   | macOS                                           | Windows                                   |
| ------ | --------------------------------------- | ----------------------------------------------- | ----------------------------------------- |
| 4.7.4  |                                         | [4.7.4-macosx-10.6-g++][4.7.4-m]                |                                           |
| 4.8.6  | [4.8.6-centos-5.5][4.8.6-l] (GLIBC 2.5) |                                                 | [4.8.6-vs2008][4.8.6-w]                   |
| 5.11.2 |                                         |                                                 | [5.11.2-static-ltcg-msvc2017-x86][5.11.2] |
| 5.15.2 |                                         | [qt-5.15.2-macosx10.13-static-x86_64][5.15.2-m] |                                           |

[4.7.4-m]: https://github.com/jcfr/qt-static-build/releases/tag/4.7.4-macosx-10.6-g%2B%2B
[4.8.6-l]: https://github.com/jcfr/qt-static-build/releases/tag/4.8.6-centos-5.5
[4.8.6-w]: https://github.com/jcfr/qt-static-build/releases/tag/4.8.6-vs2008
[5.11.2]: https://github.com/jcfr/qt-static-build/releases/tag/applauncher-5.11.2-vs2017
[5.15.2-m]: https://github.com/jcfr/qt-static-build/releases/tag/qt-5.15.2-macosx10.13-static-x86_64
