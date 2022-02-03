set -ex

# CENTOS_VERSION=`cat /etc/os-release |grep -oP '(?<=VERSION_ID=")\d+'`

systemctl set-default multi-user.target

# stop NetworkManager as it has bad effect to many services, i.e. ovs
# systemctl stop NetworkManager.service
# systemctl disable NetworkManager.service

# set the default gw interface
# echo 'GATEWAY="192.168.121.1"' > /etc/sysconfig/network
# echo 'supersede domain-name-servers 192.168.121.1;' > /etc/dhcp/dhclient.conf
# if systemctl is-active network.service;
# then
#   systemctl restart network
# fi

# stop firewalld
systemctl stop firewalld
systemctl mask firewalld

# disable selinux
sed -i 's/SELINUX=.*/SELINUX=permissive/' /etc/selinux/config
setenforce 0

# use china pip source
cat > /etc/pip.conf <<EOF
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
[install]
trusted-host = https://pypi.tuna.tsinghua.edu.cn
EOF

# add ssh key so that VMs can ssh to each other
if [ -d /vagrant/ssh ]
then
  mkdir -p /home/vagrant/.ssh /root/.ssh
  cp -f /vagrant/ssh/id_rsa /home/vagrant/.ssh/
  cp -f /vagrant/ssh/id_rsa /root/.ssh/
  cat /vagrant/ssh/authorized_keys >> /home/vagrant/.ssh/authorized_keys
  cat /vagrant/ssh/authorized_keys >> /root/.ssh/authorized_keys
  chown -R vagrant:vagrant /home/vagrant/.ssh/
  chown -R root:root /root/.ssh
fi
