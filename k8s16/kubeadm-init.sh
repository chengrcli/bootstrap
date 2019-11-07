set -x
set -e
myip=`ip a s eth0 | grep inet | grep -v inet6 | sed "s/.*inet //" | cut -f1 -d'/'`
init_params=" --pod-network-cidr 192.168.64.0/20 --apiserver-advertise-address $myip --node-name $(hostname)"
kubeadm init $init_params

chmod 644 /etc/kubernetes/admin.conf
export KUBECONFIG=/etc/kubernetes/admin.conf
grep -q KUBECONFIG /etc/environment || echo "KUBECONFIG=/etc/kubernetes/admin.conf" >> /etc/environment
echo "alias pod='kubectl get pod --all-namespaces'" > /etc/profile.d/alias.sh
kubectl apply -f /vagrant/kube-flannel.yml
kubectl taint nodes --all node-role.kubernetes.io/master-
