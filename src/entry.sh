#!/usr/bin/env bash
set -Eeuo pipefail

echo "❯ Starting QEMU for Docker v$(</run/version)..."
echo "❯ For support visit https://github.com/qemu-tools/qemu-docker/"

cd /run

. reset.sh      # Initialize system
[[ "$NO_INSTALL" != "TRUE" ]] && . install.sh

. display.sh    # Initialize display
# . network.sh    # Initialize network
NET_OPTS=""
. boot.sh       # Configure boot
. cpu.sh        # Initialize processor
. config.sh     # Configure arguments

trap - ERR
info "Booting image using $VERS..."

[[ "$DEBUG" == [Yy1]* ]] && set -x
exec qemu-system-x86_64 ${ARGS:+ $ARGS}
