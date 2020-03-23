#!/bin/bash
################################################################################
##  File:  git.sh
##  Desc:  Installs Git
################################################################################

HUB_VERSION=2.14.2
ARCH=$(dpkg --print-architecture)
ARCH=${ARCH/hf/}

# Source the helpers for use with the script
source $HELPER_SCRIPTS/document.sh

## Install git
add-apt-repository ppa:git-core/ppa -y
apt-get update
apt-get install git -y
git --version

# Install git-lfs
curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash
apt-get install -y --no-install-recommends git-lfs

# Run tests to determine that the software installed as expected
echo "Testing git installation"
if ! command -v git; then
  echo "git was not installed"
  exit 1
fi
echo "Testing git-lfs installation"
if ! command -v git-lfs; then
  echo "git-lfs was not installed"
  exit 1
fi

# Document what was added to the image
echo "Lastly, document the installed versions"
# git version 2.20.1
DocumentInstalledItem "Git ($(git --version 2>&1 | cut -d ' ' -f 3))"
# git-lfs/2.6.1 (GitHub; linux amd64; go 1.11.1)
DocumentInstalledItem "Git Large File Storage (LFS) ($(git-lfs --version 2>&1 | cut -d ' ' -f 1 | cut -d '/' -f 2))"

#Install hub 2.14.1
curl -fsSL "https://github.com/github/hub/releases/download/v$HUB_VERSION/hub-linux-$ARCH-$HUB_VERSION.tgz" | tar xz -C '/tmp'
prefix=/usr "/tmp/hub-linux-$ARCH-$HUB_VERSION/install"
rm -fr "/tmp/hub-linux-$ARCH-$HUB_VERSION"

if command -v hub; then
  echo "hub CLI was installed successfully"
  DocumentInstalledItem "Hub CLI ($(hub --version | grep "hub version" | cut -d ' ' -f 3))"
else
  echo "[!] Hub CLI was not installed"
  exit 1
fi
