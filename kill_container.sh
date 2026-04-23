#!/usr/bin/env bash
# Kill any running container built from the linuxfromscratch image.
set -euo pipefail

DOCKER_ID=$(docker ps --filter ancestor=linuxfromscratch --format '{{.ID}}' | head -n1)
if [[ -n "${DOCKER_ID}" ]]; then
    echo "$DOCKER_ID"
    docker kill "$DOCKER_ID"
fi
