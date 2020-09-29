set -ex
sudo yum install -y centos-release-openstack-train.noarch
sudo yum install -y ovn-host libibverbs
sudo systemctl enable --now openvswitch
sudo systemctl enable --now ovn-controller.service

myip=`ip a s eth1 | grep inet | grep -v inet6 | sed "s/.*inet //" | cut -f1 -d'/'`
masterip=`host ovnmaster | grep 'has address' | awk '{print $NF}'`

###############################################################
##### to enable dpdk, uncomment the following lines  ##########
###############################################################
#sudo bash -c "echo 'vm.nr_hugepages=1024' > /etc/sysctl.d/hugepages.conf"
#sudo sysctl -p /etc/sysctl.d/hugepages.conf
#sudo add-apt-repository ppa:rmescandon/yq
#sudo apt update
#sudo apt install -y yq openvswitch-switch-dpdk
#sudo update-alternatives --set ovs-vswitchd /usr/lib/openvswitch-switch-dpdk/ovs-vswitchd-dpdk
#sudo yq w -i /etc/netplan/*-vagrant.yaml network.ethernets.eth1.dhcp4 false
#sudo ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-init=true
#sudo ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-socket-mem="1024"
#sudo systemctl restart ovs-vswitchd
#sudo ovs-vsctl add-br br-int -- set Bridge br-int fail-mode=secure -- set Bridge br-int datapath_type=netdev
#sudo ovs-vsctl --may-exist add-br br-phy  -- set Bridge br-phy datapath_type=netdev \
#    -- br-set-external-id br-phy bridge-id br-phy  -- set bridge br-phy fail-mode=standalone
#sudo ovs-vsctl --timeout 10 add-port br-phy eth1
#sudo ip addr add $myip/24 dev br-phy
#sudo ip link set br-phy up
#sudo ip addr flush dev eth1 2>/dev/null
#sudo ip link set eth1 up

sudo ovs-vsctl set open . external-ids:ovn-remote=tcp:$masterip:6642
sudo ovs-vsctl set open . external-ids:ovn-encap-type=geneve
sudo ovs-vsctl set open . external-ids:ovn-encap-ip=$myip
