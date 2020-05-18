#!/bin/bash -x
################################################################################
##  File:  actions-runner-install.sh
##  Desc:  Installs GitHub's Actions runner
################################################################################

set -eou pipefail

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)"


ID=$1

if [[ -n "$ID" ]]; then
  RUNNER_HOME="$DIR/actions-runner/$ID"
  RUNNER_WORK_DIRECTORY="$DIR/work/$ID"
  RUNNER_ENV_FILE="/etc/github-runner-env-$ID"
else
  RUNNER_HOME="$DIR/actions-runner"
  RUNNER_WORK_DIRECTORY="$DIR/work"
  RUNNER_ENV_FILE="/etc/github-runner-env"
fi

if [[ ! -d "$RUNNER_HOME" ]]; then
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
  echo "Extracting ${runner_file} to $RUNNER_HOME"
  mkdir -p "$RUNNER_HOME"
  tar xzf "./${runner_file}" -C "$RUNNER_HOME"
  rm -fv "./${runner_file}"
  # shellcheck disable=SC2164
  cd "$RUNNER_HOME"
  echo "RUNNER_HOME=$RUNNER_HOME" | sudo tee -a "$RUNNER_ENV_FILE"
  echo "RUNNER_WORK_DIRECTORY=$RUNNER_WORK_DIRECTORY" | sudo tee -a "$RUNNER_ENV_FILE"
  echo ""
  sudo ./bin/installdependencies.sh
  sudo chown -R runner:runner "$RUNNER_HOME"
else
  exit 0
fi
