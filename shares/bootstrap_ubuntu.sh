set -ex

## disable graphic
sudo systemctl set-default multi-user.target

sudo cp -rf /vagrant/etc /

# remove externel dns nameservers, use local net dns, most likely be 192.168.121.1
if [ -f /etc/systemd/resolved.conf ]
then
  sudo sed -i 's/DNS=.*/DNS=/' /etc/systemd/resolved.conf
  sudo sed -i 's/DNSSEC=.*/DNSSEC=false/' /etc/systemd/resolved.conf
  sudo systemctl restart systemd-resolved
fi

# configure network interface
if [ -d /etc/netplan/ ]
then
  sudo sed -i '/nameservers/d' /etc/netplan/01-netcfg.yaml
  sudo sed -i '/addresses/d' /etc/netplan/01-netcfg.yaml
  sudo netplan apply
else
  sudo sed -i '/dns/d' /etc/network/interfaces
  sudo ifdown eth0; sudo ifup eth0
fi

# add ssh key so that VMs can ssh to each other
if [ -d /vagrant/ssh ]
then
  mkdir -p /home/vagrant/.ssh
  cp -rf /vagrant/ssh/id_rsa /home/vagrant/.ssh/
  chown -R vagrant:vagrant /home/vagrant/.ssh
  cat /vagrant/ssh/authorized_keys >> /home/vagrant/.ssh/authorized_keys
fi
