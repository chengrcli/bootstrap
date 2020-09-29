sudo yum install -y centos-release-openstack-train.noarch
sudo yum install -y ovn-central libibverbs
sudo systemctl enable --now openvswitch
sudo systemctl enable --now ovn-northd.service

sudo ovn-sbctl set-connection ptcp:6642
sudo ovn-nbctl set-connection ptcp:6641
