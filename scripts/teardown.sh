#!/bin/sh

ROOT_DIR="$(dirname $(readlink -f $0))/.."
HOSTS_FILE="$ROOT_DIR/hosts"
PRIVATE_KEY_PATH="$ROOT_DIR/wishlist.pem"
TERRAFORM_DIR="$ROOT_DIR/terraform"
terraform -chdir="$TERRAFORM_DIR" destroy && rm -f "$HOSTS_FILE"
rm -f "$PRIVATE_KEY_PATH"
