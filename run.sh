#!/bin/bash
CWD=$(pwd)

DISK=$CWD/disks/metasploitable/data.qcow2

qemu-system-x86_64 \
    -nodefaults \
    -smp cpus=2,sockets=1,cores=2,threads=1 \
    -m 2048m \
    -machine type=q35,usb=off,dump-guest-core=off,hpet=off \
    -accel tcg,thread=multi,tb-size=512 \
    -nographic \
    -vga std \
    -vnc :0 \
    -device virtio-blk-pci,drive=drive-userdata,bootindex=0 \
    -drive if=none,media=disk,id=drive-userdata,file=$DISK,discard=unmap,detect-zeroes=unmap \
    -device virtio-rng-pci \
    -netdev tap,

    # -serial mon:stdio \
    # -device virtio-serial-pci,id=virtio-serial0,bus=pcie.0,addr=0x3 \
    # -cpu max,+ssse3,+sse4.1,+sse4.2 \
    # -device virtio-net-pci,romfile=,netdev=hostnet0,mac=82:cf:d0:5e:57:66,id=net0 \
    # -netdev tap,ifname=qemu,script=no,downscript=no,id=hostnet0,vhost=on,vhostfd=40 \
    # -object iothread,id=io2 \
    # -device virtio-balloon-pci,id=balloon0,bus=pcie.0,addr=0x4 \
    # -object rng-random,id=objrng0,filename=/dev/urandom \