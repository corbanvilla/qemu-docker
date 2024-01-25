#!/usr/bin/env bash
set -Eeuo pipefail

. scripts/config.sh
. scripts/network-config.sh

export KVM_ENABLED=$KVM_ENABLED
export METASPLOITABLE_ARGS=$METASPLOITABLE_ARGS

docker compose up -d metasploitable

docker compose logs -f metasploitable