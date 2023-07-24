#!/bin/bash

iptables -P FORWARD ACCEPT
sysctl -w net.ipv4.ip_forward=1

function add_network() {
  br=$1
  cidr=$2
  v6=$3

  brctl addbr $br
  ip a a $cidr dev $br
  ip link set $br up
}


function add_vlan_network() {
    br=$1
    cidr=$2
    v6=$3
    vid=$4

    ip link add link $br name $br.$vid type vlan id $vid
    ip link set $br.$vid up
    ip address add $cidr dev $br.$vid
}

add_network vmbr0 192.110.0.1/24 ipv4
add_network vmbr0 2002:1e::1/64 ipv6

add_network vmbr1 192.120.0.1/24 ipv4
add_network vmbr1 192.120.1.1/24 ipv4
add_network vmbr1 192.120.2.1/24 ipv4

add_network vmbr2 192.120.3.1/24 ipv4

add_vlan_network vmbr1 192.120.31.1/24 ipv4 31
add_vlan_network vmbr1 192.120.32.1/24 ipv4 32
add_vlan_network vmbr1 192.120.33.1/24 ipv4 33

iptables -t nat -A POSTROUTING -o eno1 -j MASQUERADE
iptables -t nat -A POSTROUTING  -o  wls3f3 -j MASQUERADE
iptables -t nat -A POSTROUTING  -o  tun0 -j MASQUERADE
iptables -t nat -A POSTROUTING  -o  tun1 -j MASQUERADE
