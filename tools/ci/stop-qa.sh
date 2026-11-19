#!/usr/bin/env bash
set -euo pipefail
[[ ${GITHUB_ACTIONS:-} == true ]] || exit 2
[[ ${QA_CONTAINER:-} =~ ^ecologistica-ci-[0-9]+-[a-zA-Z0-9_-]+$ ]] || exit 2
owner=$(docker inspect --format '{{index .Config.Labels "ecologistica.ci.run"}}' "$QA_CONTAINER")
[[ "$owner" == "$GITHUB_RUN_ID" ]] || exit 2
docker rm -f "$QA_CONTAINER" > /dev/null
