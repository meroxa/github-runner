#!/bin/bash
################################################################################
##  File:  docker-ce.sh
##  Desc:  Installs docker onto the image, but does not pre-pull any images
################################################################################

source $HELPER_SCRIPTS/apt.sh
source $HELPER_SCRIPTS/document.sh

DOCKER_PACKAGE=docker-ce

## Check to see if docker is already installed
echo "Determing if Docker ($DOCKER_PACKAGE) is installed"
if ! IsInstalled $DOCKER_PACKAGE; then
    echo "Docker ($DOCKER_PACKAGE) was not found. Installing..."
    apt-get update
    apt-get remove -y docker-ce docker-ce-cli containerd.io
    apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    add-apt-repository "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt-get update
    # Check whether we're running in a Docker container - if yes, then mask the Docker systemd units and socket
    [[ -n $(awk -F/ '$2 == "docker"' /proc/self/cgroup) ]] && systemctl mask containerd.service docker.service docker.socket
    apt-get install -y docker-ce docker-ce-cli containerd.io --no-install-recommends
    apt-get install -yf
else
    echo "Docker ($DOCKER_PACKAGE) is already installed"
fi

# Run tests to determine that the software installed as expected
echo "Testing to make sure that script performed as expected, and basic scenarios work"
if ! command -v docker; then
    echo "docker was not installed"
    exit 1
fi

## Add version information to the metadata file
echo "Documenting Docker version"
docker_version=$(docker -v)
DocumentInstalledItem "Docker ($docker_version)"
