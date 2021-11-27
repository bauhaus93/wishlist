#!/bin/sh

ROOT_DIR="$(dirname $(readlink -f $0))/.."
. "$ROOT_DIR/.env"

docker build -t "$BACKEND_DOCKER_IMAGE_BASE" \
    -f "$ROOT_DIR/docker/backend/Dockerfile-Base" \
    "$ROOT_DIR/backend"
