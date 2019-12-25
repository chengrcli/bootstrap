set -x
set -e
apt-get update
apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y docker.io kubelet=1.16.3-00 kubeadm=1.16.3-00 kubectl=1.16.3-00
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
wait
