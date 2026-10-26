#!/usr/bin/env bash
#
# Build a static qtbase on Linux or macOS and package it as <name>.tar.xz.
#
# Usage:
#
#   build-qt6.sh <qt-version> <name> <output-dir> [extra configure args...]
#
# The archive contains a single top-level <name> directory holding the Qt
# install tree. A smoke test project is built against it before packaging.
#
set -euo pipefail

qt_version=$1
name=$2
output_dir=$(mkdir -p "$3" && cd "$3" && pwd)
shift 3

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
work_dir=${QT_WORK_DIR:-$PWD/_work}
src_dir=$work_dir/src
build_dir=$work_dir/build
prefix=$work_dir/$name

qt_minor=${qt_version%.*}
archive=qtbase-everywhere-src-$qt_version.tar.xz
archive_path=archive/qt/$qt_minor/$qt_version/submodules/$archive

# The download.qt.io redirector may pick a stalled mirror, so abort slow
# transfers and fall back to other mirrors.
mirrors=(
  https://download.qt.io
  https://qt.mirror.constant.com
  https://mirrors.ocf.berkeley.edu/qt
  https://ftp.fau.de/qtproject
)
curl_args=(-fsSL --connect-timeout 30 --speed-limit 10000 --speed-time 60)

mkdir -p "$work_dir" "$src_dir" "$build_dir"
cd "$work_dir"

expected_sha256=$(curl "${curl_args[@]}" --retry 5 "https://download.qt.io/$archive_path.sha256" | cut -d' ' -f1)
downloaded=false
for mirror in "${mirrors[@]}"; do
  echo "Downloading $mirror/$archive_path"
  rm -f "$archive"
  if ! curl "${curl_args[@]}" -o "$archive" "$mirror/$archive_path"; then
    echo "Download from $mirror failed"
    continue
  fi
  if command -v sha256sum > /dev/null; then
    actual_sha256=$(sha256sum "$archive" | cut -d' ' -f1)
  else
    actual_sha256=$(shasum -a 256 "$archive" | cut -d' ' -f1)
  fi
  if [[ "$actual_sha256" == "$expected_sha256" ]]; then
    downloaded=true
    break
  fi
  echo "SHA256 mismatch for $archive from $mirror: expected $expected_sha256, got $actual_sha256"
done
if [[ "$downloaded" != true ]]; then
  echo "Failed to download $archive" >&2
  exit 1
fi
tar -xf "$archive" -C "$src_dir" --strip-components=1

# Size optimization and leaving out the built-in MIME database and time zone
# support (about 4 MB each) reduce the size of the executables linking Qt.
cd "$build_dir"
"$src_dir/configure" \
  -prefix "$prefix" \
  -release \
  -static \
  -optimize-size \
  -no-feature-mimetype-database \
  -no-feature-timezone \
  -nomake examples \
  -nomake tests \
  -no-opengl \
  -no-dbus \
  -no-icu \
  -no-openssl \
  -qt-zlib \
  -qt-libpng \
  -qt-libjpeg \
  -qt-pcre \
  -qt-harfbuzz \
  "$@"
cmake --build . --parallel
cmake --install .

cmake \
  -S "$script_dir/../tests/smoke" \
  -B "$work_dir/smoke" \
  -G Ninja \
  -DCMAKE_BUILD_TYPE:STRING=Release \
  -DCMAKE_PREFIX_PATH:PATH="$prefix"
cmake --build "$work_dir/smoke"

cd "$work_dir"
tar -cJf "$output_dir/$name.tar.xz" "$name"
echo "Created $output_dir/$name.tar.xz"
