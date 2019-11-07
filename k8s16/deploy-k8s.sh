set -x
set -e

vagrant ssh-config > .ssh_config
# deploy master node
ssh -F .ssh_config master 'sudo bash /vagrant/kubeadm-init.sh'

# join worker nodes
token=`ssh -F .ssh_config master "kubeadm token create"`
master_ip=`ssh -F .ssh_config master "ip -4 addr show dev eth0 |grep -oP '192.168.\d{1,3}.\d{1,3}(?=/24)'"`
cert=`ssh -F .ssh_config master "openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der  2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'"`
ssh -F .ssh_config worker1 "sudo kubeadm join $master_ip:6443 --token $token --discovery-token-ca-cert-hash sha256:$cert"
