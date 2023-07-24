#!/bin/bash

ulimit -n 65535

sysctl -w net.netfilter.nf_conntrack_tcp_timeout_time_wait=5
sysctl -w net.netfilter.nf_conntrack_tcp_timeout_fin_wait=5
sysctl -w net.netfilter.nf_conntrack_max=1000000
