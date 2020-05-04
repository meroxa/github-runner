#!/bin/bash -x
################################################################################
##  File:  actions-runner.sh
##  Desc:  Installs GitHub's Actions runner
################################################################################
TARGETPLATFORM=$2

echo "PWD: $(pwd)"

export TARGET_ARCH="x64"
if [[ $TARGETPLATFORM == "linux/arm/v7" ]]; then
  export TARGET_ARCH="arm"
elif [[ $TARGETPLATFORM == "linux/arm64" ]]; then
  export TARGET_ARCH="arm64"
fi

###
# Following portion taken from:
# https://github.com/actions/runner/blob/master/scripts/create-latest-svc.sh
###
#---------------------------------------
# Download latest released and extract
#---------------------------------------
echo
echo "Downloading latest runner ..."

# For the GHES Alpha, download the runner from github.com
latest_version_label=$(curl -s -X GET 'https://api.github.com/repos/actions/runner/releases/latest' | jq -r '.tag_name')
latest_version=$(echo ${latest_version_label:1})
runner_file="actions-runner-linux-x64-${latest_version}.tar.gz"

if [ -f "${runner_file}" ]; then
    echo "${runner_file} exists. skipping download."
else
    runner_url="https://github.com/actions/runner/releases/download/${latest_version_label}/${runner_file}"

    echo "Downloading ${latest_version_label} for linux ..."
    echo $runner_url

    curl -O -L ${runner_url}
fi

ls -la *.tar.gz

#---------------------------------------------------
# extract to actions-runner directory in /home/runner
#---------------------------------------------------
echo
echo "Extracting ${runner_file} to ${RUNNER_HOME}/actions-runner"
mkdir -p "${RUNNER_HOME}"/actions-runner
tar xzf "./${runner_file}" -C "${RUNNER_HOME}"/actions-runner
# shellcheck disable=SC2164
cd "${RUNNER_HOME}"/actions-runner
echo "RUNNER_HOME=$RUNNER_HOME" | tee -a /etc/environment
echo "RUNNER_WORK_DIRECTORY=$RUNNER_HOME/work" | tee -a /etc/environment
./bin/installdependencies.sh
