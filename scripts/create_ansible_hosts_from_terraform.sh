#!/bin/sh

ROOT_DIR="$(dirname $(readlink -f $0))/.."
HOSTS_FILE="$ROOT_DIR/hosts"
PRIVATE_KEY_PATH="$ROOT_DIR/wishlist.pem"
TERRAFORM_DIR="$ROOT_DIR/terraform"
WISHLIST_GRP="aws_wishlist"

rm -f "$HOSTS_FILE" && \
    terraform -chdir="$TERRAFORM_DIR" output -raw instance_ssh_private_key_pem  > "$PRIVATE_KEY_PATH" && \
    chmod 0600 "$PRIVATE_KEY_PATH" && \
    echo "[$WISHLIST_GRP:vars]" >> "$HOSTS_FILE" &&
    echo "ansible_ssh_private_key_file=$PRIVATE_KEY_PATH" >> "$HOSTS_FILE" && \
    echo "[$WISHLIST_GRP]" >> "$HOSTS_FILE"  && \
    terraform -chdir="$TERRAFORM_DIR" output -raw instance_public_ip >> "$HOSTS_FILE"
