systemctl set-default multi-user.target
systemctl stop systemd-resolved.service
systemctl disable systemd-resolved.service
sed -i 's/4.2.2.1/10.248.2.5/' /etc/netplan/01-netcfg.yaml
sed -i 's/4.2.2.2/10.239.27.228/' /etc/netplan/01-netcfg.yaml
sed -i 's/, 208.67.220.220//' /etc/netplan/01-netcfg.yaml
parted -a optimal /dev/sda ---pretend-input-tty resizepart 3 yes 100%
resize2fs /dev/sda3
rm -f /etc/resolv.conf && cp -r /vagrant/etc /
echo 'export LC_ALL=C.UTF-8' >> /etc/profile
