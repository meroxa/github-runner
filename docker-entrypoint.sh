#!/bin/bash
###
# Originally, with significant changes to run the github runner:
# https://github.com/AkihiroSuda/containerized-systemd/blob/master/docker-entrypoint.sh

set -eou pipefail

container=docker
export container

source /etc/environment

systemctl set-default multi-user.target
systemctl mask systemd-firstboot.service
systemctl unmask systemd-logind

if [[ ! -t 0 ]]; then
  # shellcheck disable=SC2016
  echo >&2 'ERROR: TTY needs to be enabled (`docker run -t ...`).'
  exit 1
fi

##
# The base image from https://github.com/terradatum/docker-systemd includes a systemd target which accounts for a CMD.
# This checks to make sure there is no CMD, and creates the environment for the github-runner service to be configured
# and run.
if [ $# -eq 0 ]; then

  {
    echo '[Journal]'
    echo 'Storage=volatile'
    echo 'ForwardToConsole=yes'
    echo 'TTYPath=/dev/console'
    echo 'MaxLevelConsole=debug'
  } >/etc/systemd/system/journald.conf

  ###
  # Ensure the runner user has access to the docker socket - this is MUCH better than changing the permissions on docker.sock.
  # In order to avoid an error like "groups: cannot find name for group ID 969," make sure to start Docker with
  # "--group-add=$(stat -c '%g' /var/run/docker.sock)".
  DOCKER_GID=$(stat -c '%g' /var/run/docker.sock)

  # Create a "dockerhost" group with the correct GID if it doesn't exist.
  if [[ "$(cut -d: -f3 < <(getent group "$DOCKER_GID"))" == "" ]]; then
    sudo groupadd -g "$DOCKER_GID" dockerhost
    sudo usermod -aG "$DOCKER_GID" runner
  fi

  # If the $RUNNER_WORK_DIRECTORY doesn't exist, create it and set the correct permissions
  if [[ ! -d "$RUNNER_WORK_DIRECTORY" ]]; then
    mkdir -p "$RUNNER_WORK_DIRECTORY"
    sudo chown -R runner:runner "$RUNNER_WORK_DIRECTORY"
  fi

  if [[ -z $RUNNER_REPOSITORY_URL ]]; then
    echo "Error : You need to set the RUNNER_REPOSITORY_URL environment variable."
    exit 1
  fi

  if [[ -n "${ACCESS_TOKEN}" ]]; then
    URI=https://api.github.com
    API_VERSION=v3
    API_HEADER="Accept: application/vnd.github.${API_VERSION}+json"
    AUTH_HEADER="Authorization: token ${ACCESS_TOKEN}"

    _PROTO="$(echo "${RUNNER_REPOSITORY_URL}" | grep :// | sed -e's,^\(.*://\).*,\1,g')"
    _URL="${RUNNER_REPOSITORY_URL/${_PROTO}/}"
    _PATH="$(echo "${_URL}" | grep / | cut -d/ -f2-)"
    _ACCOUNT="$(echo "${_PATH}" | cut -d/ -f1)"
    _REPO="$(echo "${_PATH}" | cut -d/ -f2)"

    RUNNER_TOKEN="$(curl -XPOST -fsSL \
      -H "${AUTH_HEADER}" \
      -H "${API_HEADER}" \
      "${URI}/repos/${_ACCOUNT}/${_REPO}/actions/runners/registration-token" |
      jq -r '.token')"

    # PREVENT ACCESS_TOKEN FROM LEAKING INTO THE ENVIRONMENT
    unset ACCESS_TOKEN
  elif [[ -z $RUNNER_TOKEN ]]; then
    echo "Error : You need to set either the ACCESS_TOKEN or RUNNER_TOKEN environment variable."
    exit 1
  fi

  RUNNER_REPLACE=""
  if [ "$(echo "$RUNNER_REPLACE_EXISTING" | tr '[:upper:]' '[:lower:]')" == "true" ]; then
    RUNNER_REPLACE="--replace"
  fi

  if [[ -n "$RUNNER_LABELS" ]]; then
    RUNNER_LABELS="--labels $RUNNER_LABELS"
  fi

  env >/etc/github-runner-env

  systemctl enable github-runner-config.service
  systemctl enable github-runner.service

  systemd_args="--show-status=false --unit=github-runner.target"

fi

systemd=
if [ -x /lib/systemd/systemd ]; then
  systemd=/lib/systemd/systemd
elif [ -x /usr/lib/systemd/systemd ]; then
  systemd=/usr/lib/systemd/systemd
elif [ -x /sbin/init ]; then
  systemd=/sbin/init
else
  echo >&2 'ERROR: systemd is not installed'
  exit 1
fi

echo "$0: starting $systemd $systemd_args"
exec $systemd $systemd_args
