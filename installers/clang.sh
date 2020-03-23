#!/bin/bash
################################################################################
##  File:  clang.sh
##  Desc:  Installs Clang compiler (versions: 6, 8 and 9)
################################################################################

ARCH=$(dpkg --print-architecture)

# Source the helpers for use with the script
source $HELPER_SCRIPTS/document.sh
source $HELPER_SCRIPTS/apt.sh

function TestAndDocument() {
  version=$1
  # Run tests to determine that the software installed as expected
  echo "Testing to make sure that script performed as expected, and basic scenarios work"
  for cmd in clang-$version clang++-$version; do
    if ! command -v $cmd; then
      echo "$cmd was not installed"
      exit 1
    fi
  done

  # Document what was added to the image
  echo "Documenting clang-$version..."
  DocumentInstalledItem "Clang $version ($(clang-$version --version | head -n 1 | cut -d ' ' -f 3 | cut -d '-' -f 1))"
}
function InstallClangScript() {
  version=$1

  echo "Installing clang-$version..."

  ./llvm.sh $version
  apt-get install -y "clang-format-$version"

  TestAndDocument $version
}

function InstallClangApt() {
  version=$1

  echo "Installing clang-$version..."

  apt-get install -y "clang-$version" "clang-format-$version" "lldb-$version" "lld-$version"

  TestAndDocument $version
}


if [[ "$ARCH" == "amd64" ]]; then
  # Install Clang compiler
  wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -
  apt-add-repository "deb http://apt.llvm.org/$(lsb_release -cs)/ llvm-toolchain-$(lsb_release -cs)-6.0 main"
  apt-get update -y

  # Download script for automatic installation
  wget https://apt.llvm.org/llvm.sh
  chmod +x llvm.sh
  sed -i '/^LLVM_VERSION_PATTERNS\[9\]="-9"/i LLVM_VERSION_PATTERNS\[8\]="-8"' llvm.sh

  versions=(
    "6.0"
    "8"
    "9"
    "10"
    "11"
  )

  for version in ${versions[*]}; do
    if [[ $version == 6* ]]; then
      InstallClangApt $version
    else
      InstallClangScript $version
    fi
  done

  # Make Clang 9 default
  update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-9 100
  update-alternatives --install /usr/bin/clang clang /usr/bin/clang-9 100
  update-alternatives --install /usr/bin/clang-format clang-format /usr/bin/clang-format-9 100

  rm llvm.sh
else

  versions=(
    "6.0"
    "8"
  )

  for version in ${versions[*]}; do
    InstallClangApt $version
  done

  # Make Clang 8 default
  update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-8 100
  update-alternatives --install /usr/bin/clang clang /usr/bin/clang-8 100
  update-alternatives --install /usr/bin/clang-format clang-format /usr/bin/clang-format-8 100
fi
