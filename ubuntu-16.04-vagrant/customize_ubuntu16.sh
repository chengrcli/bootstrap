sudo parted /dev/sda resizepart 3 yes 100%
sudo resize2fs /dev/sda3
sudo sed -i '/dns/d' /etc/network/interfaces
sudo cp -r /vagrant/etc /
sudo ifdown eth0; sudo ifup eth0
sudo bash -c "echo 'export LC_ALL=en_US' >> /etc/profile"
