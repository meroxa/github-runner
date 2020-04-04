#!/bin/bash
################################################################################
##  File:  auto.sh
##  Desc:  Installs intuit's auto
################################################################################

# Source the helpers for use with the script
source $HELPER_SCRIPTS/document.sh

curl -s https://api.github.com/repos/intuit/auto/releases/latest \
| grep 'browser_download_url.*gz"' \
| cut -d : -f 2,3 \
| tr -d \" \
| xargs -n 1 curl -sSL \
| gunzip > /usr/bin/auto
chmod +x /usr/bin/auto

# Run tests to determine that the software installed as expected
echo "Testing to make sure that script performed as expected, and basic scenarios work"
if ! command -v auto; then
    echo "auto was not installed or found on PATH"
    exit 1
fi

# Document what was added to the image
echo "Lastly, documenting what we added to the metadata file"
DocumentInstalledItem "auto ($(auto --version))"
