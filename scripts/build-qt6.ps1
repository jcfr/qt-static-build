<#
Build a static qtbase with MSVC and package it as <Name>.tar.xz.

Must be run from an MSVC developer environment for the target architecture.
The archive contains a single top-level <Name> directory holding the Qt
install tree. A smoke test project is built against it before packaging.

Usage:

  build-qt6.ps1 -QtVersion <version> -Name <name> -OutputDir <dir> [-WorkDir <dir>]
#>
param(
  [Parameter(Mandatory)] [string] $QtVersion,
  [Parameter(Mandatory)] [string] $Name,
  [Parameter(Mandatory)] [string] $OutputDir,
  # Short paths avoid exceeding MAX_PATH while building Qt
  [string] $WorkDir = "C:\q"
)

$ErrorActionPreference = "Stop"

function Invoke-Checked {
  $Command, $Arguments = $args
  & $Command @Arguments
  if ($LastExitCode -ne 0) { throw "Command failed with exit code ${LastExitCode}: $args" }
}

$SmokeDir = Join-Path $PSScriptRoot "..\tests\smoke"
$OutputDir = (New-Item -ItemType Directory -Force $OutputDir).FullName
$SrcDir = Join-Path $WorkDir "s"
$BuildDir = Join-Path $WorkDir "b"
$Prefix = Join-Path $WorkDir $Name
New-Item -ItemType Directory -Force $SrcDir, $BuildDir | Out-Null

$QtMinor = $QtVersion.Substring(0, $QtVersion.LastIndexOf("."))
$Archive = Join-Path $WorkDir "qtbase-everywhere-src-$QtVersion.tar.xz"
$ArchivePath = "archive/qt/$QtMinor/$QtVersion/submodules/qtbase-everywhere-src-$QtVersion.tar.xz"

# The download.qt.io redirector may pick a stalled mirror, so abort slow
# transfers and fall back to other mirrors.
$Mirrors = @(
  "https://download.qt.io"
  "https://qt.mirror.constant.com"
  "https://mirrors.ocf.berkeley.edu/qt"
  "https://ftp.fau.de/qtproject"
)
$CurlArgs = @("-fsSL", "--connect-timeout", "30", "--speed-limit", "10000", "--speed-time", "60")

$ExpectedSha256 = ((Invoke-Checked curl.exe @CurlArgs --retry 5 "https://download.qt.io/$ArchivePath.sha256") -split "\s+")[0]
$Downloaded = $false
foreach ($Mirror in $Mirrors) {
  Write-Host "Downloading $Mirror/$ArchivePath"
  Remove-Item -Force -ErrorAction SilentlyContinue $Archive
  & curl.exe @CurlArgs -o $Archive "$Mirror/$ArchivePath"
  if ($LastExitCode -ne 0) {
    Write-Host "Download from $Mirror failed with exit code $LastExitCode"
    continue
  }
  $ActualSha256 = (Get-FileHash -Algorithm SHA256 $Archive).Hash
  if ($ActualSha256 -eq $ExpectedSha256) {
    Write-Host "Downloaded $Archive (SHA256 $ActualSha256)"
    $Downloaded = $true
    break
  }
  Write-Host "SHA256 mismatch for $Archive from ${Mirror}: expected $ExpectedSha256, got $ActualSha256"
}
if (-not $Downloaded) { throw "Failed to download $Archive" }

# The tar.exe shipped with Windows Server 2022 lacks built-in xz support and
# hangs, so extract using CMake and move the top-level directory into place.
Write-Host "Extracting $Archive"
$ExtractDir = Join-Path $WorkDir "x"
New-Item -ItemType Directory -Force $ExtractDir | Out-Null
Push-Location $ExtractDir
Invoke-Checked cmake -E tar xf $Archive
Pop-Location
Remove-Item -Recurse -Force $SrcDir
Move-Item (Join-Path $ExtractDir "qtbase-everywhere-src-$QtVersion") $SrcDir

Write-Host "Configuring Qt"

# Size optimization and leaving out the built-in MIME database and time zone
# support (about 4 MB each) reduce the size of the executables linking Qt.
# Link-time code generation (-ltcg) is not used: it did not reduce the size of
# the CTKAppLauncher executable, increased the archive size from 29 MB to
# 400 MB, and would require linking with the same MSVC toolset version.
Push-Location $BuildDir
Invoke-Checked "$SrcDir\configure.bat" `
  -prefix $Prefix `
  -release `
  -static `
  -static-runtime `
  -optimize-size `
  -no-feature-mimetype-database `
  -no-feature-timezone `
  -nomake examples `
  -nomake tests `
  -no-opengl `
  -no-dbus `
  -no-icu `
  -no-openssl `
  -qt-zlib `
  -qt-libpng `
  -qt-libjpeg `
  -qt-pcre `
  -qt-harfbuzz
Invoke-Checked cmake --build . --parallel
Invoke-Checked cmake --install .
Pop-Location

Invoke-Checked cmake `
  -S $SmokeDir `
  -B (Join-Path $WorkDir "smoke") `
  -G Ninja `
  "-DCMAKE_BUILD_TYPE:STRING=Release" `
  "-DCMAKE_MSVC_RUNTIME_LIBRARY:STRING=MultiThreaded" `
  "-DCMAKE_PREFIX_PATH:PATH=$Prefix"
Invoke-Checked cmake --build (Join-Path $WorkDir "smoke")

Push-Location $WorkDir
Invoke-Checked cmake -E tar cJf (Join-Path $OutputDir "$Name.tar.xz") $Name
Pop-Location
Write-Host "Created $OutputDir\$Name.tar.xz"
