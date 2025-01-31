#!/usr/bin/env bash
set -Eeuo pipefail

# Docker environment variables
: "${TPM:="Y"}"         # Enable TPM
: "${BOOT_MODE:="legacy"}"  # Boot mode

SECURE=""
BOOT_OPTS=""

case "${BOOT_MODE,,}" in
  uefi)
    ROM="OVMF_CODE_4M.fd"
    VARS="OVMF_VARS_4M.fd"
    ;;
  secure)
    ROM="OVMF_CODE_4M.secboot.fd"
    VARS="OVMF_VARS_4M.secboot.fd"
    ;;
  windows)
    ROM="OVMF_CODE_4M.ms.fd"
    VARS="OVMF_VARS_4M.ms.fd"
    ;;
  windows_legacy)
    BOOT_OPTS=""
    ;;
  legacy)
    BOOT_OPTS=""
    ;;
  *)
    info "Unknown boot mode '${BOOT_MODE}', defaulting to 'legacy'"
    BOOT_MODE="legacy"    
    ;;
esac

if [[ "${BOOT_MODE,,}" != "legacy" ]] && [[ "${BOOT_MODE,,}" != "windows_legacy" ]]; then

  OVMF="/usr/share/OVMF"
  DEST="$STORAGE/${BOOT_MODE,,}"

  if [ ! -f "$DEST.rom" ]; then
    [ ! -f "$OVMF/$ROM" ] && error "UEFI boot file ($OVMF/$ROM) not found!" && exit 44
    cp "$OVMF/$ROM" "$DEST.rom"
  fi

  if [ ! -f "$DEST.vars" ]; then
    [ ! -f "$OVMF/$VARS" ] && error "UEFI vars file ($OVMF/$VARS) not found!" && exit 45
    cp "$OVMF/$VARS" "$DEST.vars"
  fi

  if [[ "${BOOT_MODE,,}" != "uefi" ]]; then
    SECURE=",smm=on"
    BOOT_OPTS="$BOOT_OPTS -global driver=cfi.pflash01,property=secure,value=on"
  fi

  BOOT_OPTS="$BOOT_OPTS -drive file=$DEST.rom,if=pflash,unit=0,format=raw,readonly=on"
  BOOT_OPTS="$BOOT_OPTS -drive file=$DEST.vars,if=pflash,unit=1,format=raw"

  if [[ "${BOOT_MODE,,}" == "windows" ]]; then

    BOOT_OPTS="$BOOT_OPTS -global kvm-pit.lost_tick_policy=discard -global ICH9-LPC.disable_s3=1"

    if [[ "$TPM" == [Yy1]* ]]; then

      rm -rf /run/shm/tpm
      rm -f /var/run/tpm.pid
      mkdir -p /run/shm/tpm
      chmod 755 /run/shm/tpm

      swtpm socket -t -d --tpmstate dir=/run/shm/tpm --ctrl type=unixio,path=/run/swtpm-sock --pid file=/var/run/tpm.pid --tpm2

      for (( i = 1; i < 20; i++ )); do

        [ -S "/run/swtpm-sock" ] && break
  
        if (( i % 10 == 0 )); then
          echo "Waiting for TPM socket to become available..."
        fi

        sleep 0.1

      done

      if [ ! -S "/run/swtpm-sock" ]; then
        TPM="N"
        error "TPM socket not found? Disabling TPM support..."
      else
        BOOT_OPTS="$BOOT_OPTS -chardev socket,id=chrtpm,path=/run/swtpm-sock"
        BOOT_OPTS="$BOOT_OPTS -tpmdev emulator,id=tpm0,chardev=chrtpm -device tpm-tis,tpmdev=tpm0"
      fi

    fi
  fi

fi

return 0
