systemctl set-default multi-user.target
echo "DEFROUTE=yes" >> /etc/sysconfig/network-scripts/ifcfg-eth0
systemctl restart network
systemctl stop firewalld
systemctl mask firewalld
mkdir /root/.ssh
cp -rf /vagrant/ssh/* /root/.ssh/
cp -rf /vagrant/etc /
setenforce 0

yum install -y yum-versionlock
yum versionlock kernel*


#yum install -y e2fsprogs
#parted -a optimal /dev/vda ---pretend-input-tty resizepart 1 yes 100%
#resize2fs /dev/vda1
# echo 'export LC_ALL=C.UTF-8' >> /etc/profile
