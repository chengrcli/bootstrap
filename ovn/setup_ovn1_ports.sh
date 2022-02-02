set -ex

ip netns add vm1
ovs-vsctl add-port br-int vm1 -- set interface vm1 type=internal
ip link set vm1 address 02:ac:10:ff:01:30
ip link set vm1 netns vm1
ovs-vsctl set Interface vm1 external_ids:iface-id=dmz-vm1
ip netns exec vm1 dhclient -r
ip netns exec vm1 dhclient vm1
ip netns exec vm1 ip addr show vm1
ip netns exec vm1 ip route add default via 172.16.255.129
ip netns exec vm1 ip route show
 
ip netns add vm3
ovs-vsctl add-port br-int vm3 -- set interface vm3 type=internal
ip link set vm3 address 02:ac:10:ff:01:94
ip link set vm3 netns vm3
ovs-vsctl set Interface vm3 external_ids:iface-id=inside-vm3
ip netns exec vm3 dhclient -r
ip netns exec vm3 dhclient vm3
ip netns exec vm3 ip addr show vm3
ip netns exec vm3 ip route add default via 172.16.255.193
ip netns exec vm3 ip route show

# set up gateway
cidr=`ip --brief a s eth2 | awk '{print $3}'`
ovs-vsctl add-br br-eth2
ovs-vsctl set Open_vSwitch . external-ids:ovn-bridge-mappings=dataNet:br-eth2
ovs-vsctl add-port br-eth2 eth2
ip addr del dev eth2 $cidr
