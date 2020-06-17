##############################################
### NOTE: This script is your reference ######
### Never execute this script directly  ######
##############################################

source openrc

# There is a bug of ovs/neutron: restarting ovs recreates the router/dhcp ports,
# but not assign them to the right namespace. The fix is to delete router and subnet to let it creates ports again.
openstack router remove subnet router1 subnet1
openstack router delete router1
openstack subnet delete subnet1
openstack subnet delete provider
openstack server delete cirros{1,2}

# Bind eth1 to uio driver and add it to provider network bridge as a dpdk port
# For baremetal env, vfio-pci driver is prefered (DPDK only steps)
curl -LO https://github.com/DPDK/dpdk/raw/master/usertools/dpdk-devbind.py
chmod +x dpdk-devbind.py
modprobe uio_pci_generic
ip link set dev eth1 down
./dpdk-devbind.py -b uio_pci_generic 00:06.0
ovs-vsctl add-port br-phynet1 dpdk1 -- set Interface dpdk1 type=dpdk options:dpdk-devargs=0000:00:06.0

# Create image, flavor, network, router and VMs
test -f cirros-0.5.1-x86_64-disk.img || curl -LO http://download.cirros-cloud.net/0.5.1/cirros-0.5.1-x86_64-disk.img
openstack image create --container-format bare --disk-format qcow2 --file cirros-0.5.1-x86_64-disk.img --public cirros
openstack flavor create  --ram 512 --disk 2 --vcpus 1 --public m1.tiny
# DPDk only step
openstack flavor set m1.tiny --property hw:mem_page_size=large

openstack network create --enable net1
openstack subnet create --network net1 --dns-nameserver 10.248.2.5 --gateway 172.16.1.1 --subnet-range 172.16.1.0/24  subnet1
openstack router create router1
openstack router add subnet router1 subnet1
openstack server create --image cirros --network net1 --flavor m1.tiny cirros1
openstack server create --image cirros --network net1 --flavor m1.tiny cirros2

openstack network create  --share --external --provider-physical-network physnet1 --provider-network-type flat provider
openstack subnet create --network provider   --allocation-pool start=192.168.123.90,end=192.168.123.99 --dns-nameserver 10.248.2.5 --gateway 192.168.123.1 --subnet-range 192.168.123.0/24 provider
openstack router set router1 --external-gateway provider
