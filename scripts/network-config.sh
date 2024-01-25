#!/bin/bash
set -Eeuo pipefail

. scripts/config.sh

# Enable IP forwarding
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward > /dev/null
sudo sysctl -p


# Setup NAT rules through interface
if ! sudo iptables -t nat -C POSTROUTING -o $HOST_INTERFACE -j MASQUERADE &>/dev/null; then
    sudo iptables -t nat -A POSTROUTING -o $HOST_INTERFACE -j MASQUERADE
fi

# Allow forwarding back to vms
if ! sudo iptables -C FORWARD -j ACCEPT -o $MAIN_BRIDGE &>/dev/null; then
    sudo iptables -I FORWARD -j ACCEPT -o $MAIN_BRIDGE
fi


create_bridge () {
    echo "Creating bridge $1"

    # Create bridge
    if ! sudo ip link show $1 &>/dev/null; then
        echo "Bridge not exists"
        sudo ip link add $1 type bridge
    else
        echo "Bridge already exists"
    fi
}


create_tap () {
    echo "Creating tap $1 to bridge $2"

    # Create tap
    if ! sudo ip tuntap show dev $1 &>/dev/null; then
        echo "Creating new tap"
        sudo ip tuntap add dev $1 mode tap
        sudo ip link set dev $1 master $2
    else
        echo "Tap already exists"
    fi
}


create_bridge $MAIN_BRIDGE
create_tap $METASPLOITABLE_TAP $MAIN_BRIDGE
create_tap $KALI_TAP $MAIN_BRIDGE
create_tap $WUMPUS_TAP $MAIN_BRIDGE
create_tap $CLIENT_TAP $MAIN_BRIDGE
create_tap $SERVER_TAP $MAIN_BRIDGE

# bring up the bridge
sudo ip link set dev $MAIN_BRIDGE up

# setup host tap
if ! sudo ip address show dev $MAIN_BRIDGE | grep -q "$MAIN_BRIDGE_IP"; then
    sudo ip address add $MAIN_BRIDGE_IP dev $MAIN_BRIDGE
fi
