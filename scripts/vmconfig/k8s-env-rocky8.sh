#!/bin/bash

MIRROR=mirrors.aliyun.com/rockylinux
sudo sed -i.bak \
-e "s|^mirrorlist=|#mirrorlist=|" \
-e "s|^#baseurl=|baseurl=|" \
-e "s|dl.rockylinux.org/\$contentdir|$MIRROR|" \
/etc/yum.repos.d/Rocky-*.repo

dnf install -y wget epel-release vim tcpdump net-tools bind-utils iproute-tc

systemctl stop firewalld && systemctl disable firewalld && setenforce 0

cat > /etc/sysctl.d/k8s.conf << EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

wget https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo -O/etc/yum.repos.d/docker-ce.repo
dnf -y install docker-ce
systemctl enable docker && systemctl start docker

swapoff -a && sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
setenforce 0 && sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config


cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

dnf install -y kubelet-1.27.1 kubectl-1.27.1 kubeadm-1.27.1

mkdir -p /etc/docker
cat >/etc/docker/daemon.json <<EOF
{
  "registry-mirrors": ["https://hdi5v8p1.mirror.aliyuncs.com"],
  "exec-opts": ["native.cgroupdriver=systemd"],
  "insecure-registries" : [ "beyond.io:5000" ]
}
EOF

cat >>/etc/hosts <<EOF
#10.22.19.21 beyond.io
192.110.0.1 beyond.io
EOF

systemctl daemon-reload && systemctl restart docker && systemctl enable docker

dnf install -y autoconf automake libtool kernel-devel


cat >> /etc/bashrc <<EOF
alias apod='kubectl get pods -A -o wide'
alias asvc='kubectl get svc -A -o wide'
alias aep='kubectl get ep -A -o wide'
alias ovsbash="docker exec -it `docker ps|grep  ovs|grep supervisord| awk '{print $1}'` bash"
alias reset-ipt="iptables -F -t raw && iptables -F -t nat && iptables -F -t mangle && iptables -F -t filter"
alias clean-k8s-pod="docker rm `docker ps -a|grep k8s|awk '{print $1}'`"
alias del-e2ens='kubectl  delete ns network-policy network-policy-a network-policy-b network-policy-c fabric-e2e-test fabric-e2e'
EOF

cat >> /etc/NetworkManager/conf.d/99-unmanaged-devices.conf <<EOF
[keyfile]
unmanaged-devices=interface-name:eth1;interface-name:boc0;interface-name:vxlan_sys_4789;interface-name:fab*
EOF

# kubeadm init --kubernetes-version=v1.27.1 --service-cidr=10.96.0.0/12 --apiserver-advertise-address=192.110.0.20 --ignore-preflight-errors=Swap --image-repository registry.aliyuncs.com/google_containers
