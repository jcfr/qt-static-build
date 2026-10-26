#!/usr/bin/env bash
#
# Install the packages needed to build static qtbase (including the xcb
# platform plugin) in a manylinux_2_28 (AlmaLinux 8) container.
#
set -euo pipefail

# EPEL (needed for xcb-util-cursor-devel) mirrors are often unreachable or
# mid-sync, so replace the EPEL repo configuration (preinstalled in the
# manylinux image) with one using the primary server, and retry.
if [[ ! -f /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-8 ]]; then
  dnf install -y --disablerepo='epel*' epel-release
fi
rm -f /etc/yum.repos.d/epel*.repo
cat > /etc/yum.repos.d/epel.repo << 'EOF'
[epel]
name=Extra Packages for Enterprise Linux 8 - $basearch
baseurl=https://dl.fedoraproject.org/pub/epel/8/Everything/$basearch/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-8
EOF

for attempt in 1 2 3; do
  if dnf install -y --setopt=retries=10 \
  fontconfig-devel \
  freetype-devel \
  libX11-devel \
  libXext-devel \
  libXrender-devel \
  libxcb-devel \
  libxkbcommon-devel \
  libxkbcommon-x11-devel \
  xcb-util-cursor-devel \
  xcb-util-devel \
  xcb-util-image-devel \
  xcb-util-keysyms-devel \
  xcb-util-renderutil-devel \
  xcb-util-wm-devel \
  xz; then
    break
  fi
  if [[ $attempt -eq 3 ]]; then
    exit 1
  fi
  echo "dnf install failed (attempt $attempt), retrying"
  dnf clean metadata
  sleep 30
done

command -v ninja > /dev/null || pipx install ninja
