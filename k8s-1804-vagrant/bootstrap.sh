set -x
set -e
systemctl set-default multi-user.target
systemctl stop systemd-resolved.service
systemctl disable systemd-resolved.service
sed -i 's/4.2.2.1/10.248.2.5/' /etc/netplan/01-netcfg.yaml
sed -i 's/4.2.2.2/10.239.27.228/' /etc/netplan/01-netcfg.yaml
sed -i 's/, 208.67.220.220//' /etc/netplan/01-netcfg.yaml
parted /dev/sda resizepart 3 yes 100%
resize2fs /dev/sda3
rm -f /etc/resolv.conf
cp -r /vagrant/etc /
echo 'export LC_ALL=C.UTF-8' >> /etc/profile
export LC_ALL=C.UTF-8
apt-get update
apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
# nfs-common for nfs pv
apt-get install -y docker.io kubelet kubeadm kubectl nfs-common
apt-mark hold kubelet kubeadm kubectl

usermod -aG docker vagrant
bash /vagrant/pull-local-images.sh &
swapoff -a; sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
apt install -y crudini
crudini --set /etc/sysctl.conf "" "net.bridge.bridge-nf-call-iptables" "1"
sysctl -p /etc/sysctl.conf
myip=`ip a s eth0 | grep inet | grep -v inet6 | sed "s/.*inet //" | cut -f1 -d'/'`
echo "KUBELET_EXTRA_ARGS= --node-ip=$myip" > /etc/default/kubelet
systemctl restart kubelet
