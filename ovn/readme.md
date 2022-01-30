# ovn

This vagrant setup 3 nodes ovn cluster, ovnmaster is the master node which
does not run ovs for pkt forwarding. 

1. run `vagrant up` brings up the cluster
1. login ovnmaster and run `sudo bash /vagrant/setup_virtual_network.sh` to
set up virtual network topology (see the following diagram for topology detail)
1. login ovn1 and run `sudo bash /vagrant/setup_ovn1_ports.sh` to setup ovs ports
1. login ovn2 and run `sudo bash /vagrant/setup_ovn2_ports.sh` to setup ovs ports
and gw


## practices

1. vm1 ping vm2 (same subnet but different hosts)
```bash
# on host ovn1
ip netns exec vm1 ping -c 3 172.16.255.131
```

1. vm1 ping vm3 (different subnet but same host)
```bash
# on host ovn1
ip netns exec vm1 ping -c 3 172.16.255.194
```

1. vm1 ping physical net
```bash
# on host ovn1
phy_ip=`ssh -o StrictHostKeyChecking=no ovnmaster ip --brief a s eth2 | grep -oP "\d+\.\d+\.\d+\.\d+"`
ip netns exec vm1 ping -c 3 $phy_ip
```



+-----------------------------------------------+
|  outside-localnet(dataNet)                    |
|                                               |
|                                               |
|                                               |
|                                               |
|             sw outside                        |
|        192.168.124.0/24                       |
|                                               |
|            outside-edge1                      |
+----------------+------------------------------+
                 |
                 |
+-----------------------------------+
|         edge1-outside             |
|         192.168.124.xx/24         |
|         02:0a:7f:00:01:29         |
|                                   |
|                                   |
|                                   |
|    router edge1                   |
|                                   |
|                                   |
| 02:ac:10:ff:00:01                 |
| 172.16.255.1                      |
| edge1-transit                     |
+----+------------------------------+
     |                                                          
     |                                                          
     |                                                          
+----+------------------------------+
| transit-edge1                     |
|                                   |
|             sw transit            |
|        172.16.255.0/30            |
|                                   |
|            transit-tenant1        |
+----------------+------------------+
                 |
                 |
+-----------------------------------------------------------------------------+
|         tenant1-transit                                                     |
|         172.16.255.2/30                                                     |
|                                                                             |
|                                                                             |
|    router tenant1                                                           |
|                                                                             |
|                                                                             |
| 02:ac:10:ff:01:29                                       02:ac:10:ff:01:93   |
| 172.16.255.129                                          172.16.255.193      |
| tenant1-dmz                                             tenant1-inside      |
+----+----------------------------------------------------------+-------------+
     |                                                          |
     |                                                          |
     |                                                          |
+----+------------------------------+         +-----------------+-------------+
| dmz-tenant1                       |         |           inside-tenant1      |
|                                   |         |                               |
|             sw dmz                |         |           sw inside           |
|        172.16.255.128/26          |         |        172.16.255.192/26      |
|                                   |         |                               |
|  dmz-vm1                 dmz-vm2  |         | inside-vm1       inside-vm2   |
+-----+-----------------------+-----+         +-------+--------------+--------+
      |                       |                       |              |
      |                       |                       |              |
      |                       |                       |              |
+-----+------------+  +-------+-----------+  +--------+--------+   +-----+------------+
| 02:ac:10:ff:01:30|  | 02:ac:10:ff:01:31 |  |02:ac:10:ff:01:94|   | 02:ac:10:ff:01:95|
| 172.16.255.130   |  | 172.16.255.131    |  | 172.16.255.194  |   | 172.16.255.195   |
|      vm1         |  |      vm2          |  |     vm3         |   |     vm4          |
+-------------------  +-------------------+  +-----------------+   +------------------+


## references

- https://www.ovn.org/support/dist-docs/ovn-architecture.7.txt
- https://www.cnblogs.com/YaoDD/p/7476085.html
- https://l8liliang.github.io/2021/05/31/ovn-router.html
