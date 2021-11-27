#!/bin/sh


ROOT_DIR="$(dirname $(readlink -f $0))/.."

export PROJECT_NAME="wishlist"
export BACKEND_DOCKER_IMAGE_BASE="$PROJECT_NAME-backend-base"
export BACKEND_DOCKER_IMAGE="schlemihl/$PROJECT_NAME-backend"

