set -ex

systemctl set-default multi-user.target

# make eth0 as the default gw interface
echo "DEFROUTE=yes" >> /etc/sysconfig/network-scripts/ifcfg-eth0
systemctl restart network

# stop firewalld
systemctl stop firewalld
systemctl mask firewalld

# disable selinux
sed -i 's/SELINUX=.*/SELINUX=permissive/' /etc/selinux/config
setenforce 0

# add ssh key so that VMs can ssh to each other
if [ -d /vagrant/ssh ]
then
  mkdir -p /home/vagrant/.ssh
  cp -f /vagrant/ssh/id_rsa /home/vagrant/.ssh/
  chown -R vagrant:vagrant /home/vagrant/.ssh/
  cat /vagrant/ssh/authorized_keys >> /home/vagrant/.ssh/authorized_keys
fi
