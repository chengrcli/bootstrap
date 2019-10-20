set -x
set -e
sshkey="/vagrant/.vagrant/machines/master/virtualbox/private_key"
token=`ssh -o StrictHostKeyChecking=no -i $sshkey vagrant@192.168.11.10 "kubeadm token create"` 
cert=`ssh -o StrictHostKeyChecking=no -i $sshkey vagrant@192.168.11.10 "openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der  2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'"`
kubeadm join 192.168.11.10:6443 --token $token --discovery-token-ca-cert-hash sha256:$cert

scp -o StrictHostKeyChecking=no -i $sshkey vagrant@192.168.11.10:/etc/kubernetes/admin.conf /etc/kubernetes/admin.conf
chmod 644 /etc/kubernetes/admin.conf
export KUBECONFIG=/etc/kubernetes/admin.conf
grep -q KUBECONFIG || echo "KUBECONFIG=/etc/kubernetes/admin.conf" >> /etc/environment
echo "alias pod='kubectl get pod --all-namespaces'" > /etc/profile.d/alias.sh
