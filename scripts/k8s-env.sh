#!/bin/bash

yum install -y wget && wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo && yum clean all && yum makecache
yum -y install epel-release vim

systemctl stop firewalld && systemctl disable firewalld && setenforce 0

cat > /etc/sysctl.d/k8s.conf << EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

wget https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo -O/etc/yum.repos.d/docker-ce.repo
yum -y install docker-ce
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

yum install -y kubelet-1.21.1 kubectl-1.21.1 kubeadm-1.21.1

mkdir /etc/docker
cat >/etc/docker/daemon.json <<EOF
{
  "registry-mirrors": ["https://hdi5v8p1.mirror.aliyuncs.com"],
  "exec-opts": ["native.cgroupdriver=systemd"],
  "insecure-registries" : [ "beyond.io:5000" ]
}
EOF

cat >>/etc/hosts <<EOF
10.20.19.21 beyond.io
EOF

systemctl daemon-reload && systemctl restart docker && systemctl enable docker

yum -y install install autoconf automake libtool kernel-devel

# kubeadm init --kubernetes-version=v1.21.1 --service-cidr=10.96.0.0/12 --ignore-preflight-errors=Swap --image-repository registry.aliyuncs.com/google_containers
