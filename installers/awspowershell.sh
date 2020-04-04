#!/bin/bash
################################################################################
##  File:  awspowershell.sh
##  Desc:  Install AWS PowerShell
################################################################################

# Source the helpers for use with the script
source $HELPER_SCRIPTS/document.sh

sudo pwsh -Command 'Save-Module -Name AWSPowerShell.NetCore -LiteralPath /usr/share/awspowershell_4.0.4.0 -RequiredVersion 4.0.4.0 -Force'
sudo pwsh -Command 'Save-Module -Name AWSPowerShell.NetCore -LiteralPath /usr/share/awspowershell_4.0.2.0 -RequiredVersion 4.0.2.0 -Force'
sudo pwsh -Command 'Save-Module -Name AWSPowerShell.NetCore -LiteralPath /usr/share/awspowershell_3.3.618.0 -RequiredVersion 3.3.618.0 -Force'

# Run tests to determine that the software installed as expected
echo "Testing to make sure that script performed as expected, and basic scenarios work"
if ! pwsh -Command '$actualPSModulePath = $env:PSModulePath ; $env:PSModulePath = "/usr/share/awspowershell_4.0.4.0:" + $env:PSModulePath;
    if (!(get-module -listavailable -name AWSPowerShell.NetCore)) {
        Write-Host "AWSPowerShell.NetCore Module was not installed"; $env:PSModulePath = $actualPSModulePath; exit 1
    }
    $env:PSModulePath = $actualPSModulePath
    $actualPSModulePath = $env:PSModulePath ; $env:PSModulePath = "/usr/share/awspowershell_4.0.2.0:" + $env:PSModulePath;
    if (!(get-module -listavailable -name AWSPowerShell.NetCore)) {
        Write-Host "AWSPowerShell.NetCore Module was not installed"; $env:PSModulePath = $actualPSModulePath; exit 1
    }
    $env:PSModulePath = $actualPSModulePath
    $actualPSModulePath = $env:PSModulePath ; $env:PSModulePath = "/usr/share/awspowershell_3.3.618.0:" + $env:PSModulePath;
    if (!(get-module -listavailable -name AWSPowerShell.NetCore)) {
        Write-Host "AWSPowerShell.NetCore Module was not installed"; $env:PSModulePath = $actualPSModulePath; exit 1
    }
    $env:PSModulePath = $actualPSModulePath'; then
    exit 1
fi

# Document what was added to the image
echo "Lastly, documenting what we added to the metadata file"
DocumentInstalledItem "AWSPowerShell.NetCore Module:"
DocumentInstalledItemIndent "4.0.4.0"
DocumentInstalledItemIndent "4.0.2.0"
DocumentInstalledItemIndent "3.3.618.0"