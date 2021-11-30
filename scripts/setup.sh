#!/bin/sh

ROOT_DIR="$(dirname $(readlink -f $0))/.."
TERRAFORM_DIR="$ROOT_DIR/terraform"
terraform -chdir="$TERRAFORM_DIR" apply && \
    "$ROOT_DIR/scripts/create_ansible_hosts_from_terraform.sh" && \
    ansible-playbook -i "$ROOT_DIR/hosts" "$ROOT_DIR/ansible/init.yml"
