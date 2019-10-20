which helm || (
curl -LO https://storage.googleapis.com/kubernetes-helm/helm-v2.12.1-linux-amd64.tar.gz
tar -xzvf helm-v2.12.1-linux-amd64.tar.gz
sudo cp linux-amd64/helm /usr/local/bin/
)
kubectl create clusterrolebinding tiller-cluster-admin2 --clusterrole=cluster-admin --serviceaccount=kube-system:default
helm init

sudo -E tee /etc/systemd/system/helm-serve.service <<EOF
[Unit]
Description=Helm Server
After=network.target

[Service]
User=$(id -un 2>&1)
Restart=always
ExecStart=/usr/local/bin/helm serve

[Install]
WantedBy=multi-user.target
EOF

sudo chmod 0640 /etc/systemd/system/helm-serve.service
sudo systemctl restart helm-serve
sudo systemctl daemon-reload
sudo systemctl enable helm-serve


# NOTE: Set up local helm repo
helm repo add local http://localhost:8879/charts
helm repo update


# NOTE: Set required labels on host(s)
kubectl label nodes --all openstack-control-plane=enabled
kubectl label nodes --all openstack-compute-node=enabled
kubectl label nodes --all openvswitch=enabled
kubectl label nodes --all linuxbridge=enabled
kubectl label nodes --all ceph-mon=enabled
kubectl label nodes --all ceph-osd=enabled
kubectl label nodes --all ceph-mds=enabled
kubectl label nodes --all ceph-rgw=enabled
kubectl label nodes --all ceph-mgr=enabled
