#!/bin/bash
################################################################################
##  File:  cmake.sh
##  Desc:  Installs CMake
################################################################################

# Source the helpers for use with the script
source $HELPER_SCRIPTS/document.sh

apt-get install -y cmake

# Run tests to determine that the software installed as expected
echo "Testing to make sure that script performed as expected, and basic scenarios work"
if ! command -v cmake; then
    echo "cmake was not installed"
    exit 1
fi

# Document what was added to the image
echo "Lastly, documenting what we added to the metadata file"
DocumentInstalledItem "CMake ($(cmake --version | head -n 1))"
