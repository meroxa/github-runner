#!/bin/bash

set -eou pipefail

if [[ ! -f "$RUNNER_HOME/actions-runner/.runner" && -x "$RUNNER_HOME/actions-runner/config.sh" ]]; then
  cd "$RUNNER_HOME"/actions-runner
  "$RUNNER_HOME"/actions-runner/config.sh \
    --url "$RUNNER_REPOSITORY_URL" \
    --token "$RUNNER_TOKEN" \
    --work "$RUNNER_WORK_DIRECTORY" \
    $RUNNER_REPLACE \
    $RUNNER_LABELS \
    --unattended
else
  exit 0
fi
