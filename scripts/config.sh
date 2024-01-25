# Host config
MAIN_BRIDGE_IP=10.10.0.1/24
MAIN_BRIDGE=br-vmnet
HOST_INTERFACE=eth0

# Enable KVM
KVM_ENABLED=N

# VMs
METASPLOITABLE_TAP=tap-msf
METASPLOITABLE_ARGS="-netdev tap,id=net0,ifname=$METASPLOITABLE_TAP,script=no,downscript=no -device virtio-net-pci,netdev=net0"

KALI_TAP=tap-kali
WUMPUS_TAP=tap-wumpus
CLIENT_TAP=tap-client
SERVER_TAP=tap-server
