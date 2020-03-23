#!/bin/bash
################################################################################
##  File:  repos.sh
##  Desc:  Installs official Microsoft package repos for the distribution
################################################################################

LSB_RELEASE=$(lsb_release -rs)
ARCH=$(dpkg --print-architecture)

# Install Microsoft repository
if [[ "$ARCH" == "amd64" ]]; then
  wget https://packages.microsoft.com/config/ubuntu/$LSB_RELEASE/packages-microsoft-prod.deb
else
  wget https://packages.microsoft.com/config/ubuntu/$LSB_RELEASE/multiarch/packages-microsoft-prod.deb
fi
dpkg -i packages-microsoft-prod.deb
apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Install Microsoft GPG public key
curl -L https://packages.microsoft.com/keys/microsoft.asc | apt-key add -

curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
apt-get update