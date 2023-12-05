#!/bin/bash

# backup: 
# /etc/hosts
# /etc/bash.bashrc 
# /home/lb/
# /etc/rc.local
# /var/lib/libvirt/
# /root/anaconda3/

apt update
apt install -y vim curl fcitx net-tools git terminator shutter synaptic xserver-xorg-input-synaptics libqt5qml5 libqt5quick5 libqt5quickwidgets5 qml-module-qtquick2 libgsettings-qt1 p7zip-full make gcc  \
	openssl openssh-server uml-utilities apt-transport-https ca-certificates curl gnupg-agent software-properties-common selinux-utils conntrack aptitude libbpf-dev libbfd-dev libcap-dev protobuf-compiler musl-tools \
	cpu-checker qemu-kvm virt-manager libvirt-daemon-system virtinst libvirt-clients bridge-utils tmux tilix sshpass iostat iotop

### If use compute book, may install
# apt install -y laptop-mode-tools

### System
ufw disable && systemctl disable ufw && systemctl stop ufw
echo SELINUX=disabled > /etc/selinux/config && setenforce 0
update-alternatives --set  iptables /usr/sbin/iptables-legacy
swapoff -a && sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

cat >>/etc/hosts <<EOF

#10.22.19.21 beyond.io bocloud-bj.io
192.110.0.1 beyond.io bocloud-bj.io
EOF


### Docker
mkdir -p /etc/docker
cat >/etc/docker/daemon.json <<EOF
{
  "registry-mirrors": ["https://hdi5v8p1.mirror.aliyuncs.com"],
  "exec-opts": ["native.cgroupdriver=systemd"],
  "insecure-registries" : [ "beyond.io:5000" , "abcsys.cn:5000", "registry163.bocloud.com:5000", "deploy.bocloud.k8s:40443", "http://bocloud-bj.io:5000", "http://beyond.io:5000", "bocloud-bj.io:5000"]
}
EOF

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker-archive-keyring.gpg
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update
apt install -y docker-ce docker-ce-cli containerd.io

### Add your user account to docker group.
usermod -aG docker lb
newgrp docker

curl https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main
EOF

git config --global credential.helper store


#curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg
#echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
#apt update
apt install kubeadm=1.21.14-00 kubelet=1.21.14-00 kubectl=1.21.14-00
apt-mark hold kubeadm kubelet kubectl linux-image-* linux-headers-*

kubeadm init --kubernetes-version=v1.21.14 --apiserver-advertise-address=172.17.0.1 --service-cidr=10.96.0.0/16 --ignore-preflight-errors=Swap --image-repository registry.aliyuncs.com/google_containers -v 10