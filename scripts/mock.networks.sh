#!/bin/bash

#mount /dev/sdb1 /home/vm/sdb
#mount /dev/sdc1 /home/vm/sdc
#mount /dev/sdd1 /home/vm/sdd

function add_network() {
  br=$1
  cidr=$2
  v6=$3

  brctl addbr $br
  ip a a $cidr dev $br
  ip link set $br up

  if [ "$v6" == "ipv6" ]
  then
      #ip6tables -I POSTROUTING -t nat  -o $br -j ACCEPT
      ip6tables -t nat -A POSTROUTING -s $cidr ! -o $br -j MASQUERADE
  else
      #iptables -I POSTROUTING -t nat  -o $br -j ACCEPT
      iptables -t nat -A POSTROUTING -s $cidr ! -o $br -j MASQUERADE
  fi
}

function add_vlan_network() {
    br=$1
    cidr=$2
    v6=$3
    vid=$4

    ip link add link $br name $br.$vid type vlan id $vid
    ip link set $br.$vid up
    ip address add $cidr dev $br.$vid

    if [ "$v6" == "ipv6" ]
    then
        ip6tables -t nat -I POSTROUTING -s $cidr ! -o $br.$vid -j MASQUERADE
    else
        iptables -t nat -I POSTROUTING -s $cidr ! -o $br.$vid -j MASQUERADE
    fi
}

add_network vmmgr 192.100.0.254/24 ipv4
add_network vmmgr 2002:1e::1/64 ipv6

add_network vmpod 192.110.0.254/24 ipv4
add_vlan_network vmpod 192.120.31.254/24 ipv4 31
add_vlan_network vmpod 192.120.32.254/24 ipv4 32
add_vlan_network vmpod 192.120.33.254/24 ipv4 33
add_vlan_network vmpod 192.120.34.254/24 ipv4 34
add_vlan_network vmpod 2002:64::1/64 ipv6 100
add_vlan_network vmpod 2002:22::1/64 ipv6 34


ip link add link enp2s0f1 name enp2s0f1.21 type vlan id 21
brctl addif vmmgr enp2s0f1.21

iptables -P FORWARD ACCEPT
sysctl -w net.ipv4.ip_forward=1
