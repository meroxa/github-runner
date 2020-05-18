#!/bin/bash

set -eou pipefail

if [[ ! -f "$RUNNER_HOME/.runner" && -x "$RUNNER_HOME/config.sh" ]]; then
  "$RUNNER_HOME/config.sh" \
    --url "$RUNNER_REPOSITORY_URL" \
    --token "$RUNNER_TOKEN" \
    --work "$RUNNER_WORK_DIRECTORY" \
    --name "$RUNNER_NAME" \
    $RUNNER_REPLACE \
    $RUNNER_LABELS \
    --unattended
else
  exit 0
fi
