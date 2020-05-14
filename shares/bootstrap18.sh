systemctl set-default multi-user.target
#systemctl stop systemd-resolved.service
#systemctl disable systemd-resolved.service
sed -i '/nameservers/d' /etc/netplan/01-netcfg.yaml
sed -i '/addresses/d' /etc/netplan/01-netcfg.yaml
parted -a optimal /dev/sda ---pretend-input-tty resizepart 3 yes 100%
resize2fs /dev/sda3
#rm -f /etc/resolv.conf &&
cp -r /vagrant/etc /
echo 'export LC_ALL=C.UTF-8' >> /etc/profile
