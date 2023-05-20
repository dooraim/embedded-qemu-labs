#!/bin/bash

# qemu-tap-setup.sh

echo "Create a bridge"
brctl addbr br0

echo "Add enp0s2 to bridge"
brctl addif br0 enp0s2

echo "Create tap interface"
tunctl -t tap0 -u dooraim

echo "Add tap0 to bridge"
brctl addif br0 tap0

echo "Make sure everything is up"
ifconfig enp0s2 up
ifconfig tap0 up
ifconfig br0 up

echo "Check if properly bridged"
brctl show

echo "Assign ip to br0"
dhclient -v br0
