# reference doc: https://github.com/vagrant-libvirt/vagrant-libvirt#installation
if which apt&>/dev/null
then
  sudo apt update
  sudo apt install -y libvirt-bin qemu dnsmasq
  sudo apt install -y vagrant
elif which yum&>/dev/null
then
  sudo yum install -y libvirt libvirt-devel ruby-devel gcc qemu-kvm
  if [ ! -e vagrant_2.2.13_x86_64.rpm ]
  then
    curl -LO https://releases.hashicorp.com/vagrant/2.2.13/vagrant_2.2.13_x86_64.rpm
  fi
  sudo yum install -y vagrant_2.2.13_x86_64.rpm
  sudo systemctl start libvirtd
fi

# may need to login again to make new group take effect
sudo usermod -a -G libvirt $USER
vagrant plugin install vagrant-libvirt

# generate ssh key for VM access each other
mkdir -p shares/ssh
pushd shares/ssh
  if [ ! -e id_rsa ]
  then
    ssh-keygen -C "for vm access each other" -f id_rsa -N ''
    cp id_rsa.pub authorized_keys
  fi
popd
