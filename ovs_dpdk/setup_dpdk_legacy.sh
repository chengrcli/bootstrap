# export https_proxy=192.168.121.1:1080 http_proxy=192.168.121.1:1080
test -f /vagrant/v19.11.tar.gz || curl -L -o /vagrant/v19.11.tar.gz https://github.com/DPDK/dpdk/archive/v19.11.tar.gz
tar -xzvf /vagrant/v19.11.tar.gz
pushd dpdk-19.11/
  # for 19.11 and older version
  yum install -y numactl-devel
  rm -rf ./build
  rm -rf x86_64-native-linuxapp-gcc
  make config RTE_SDK=`pwd` T=x86_64-native-linuxapp-gcc
  make -j 32 install RTE_SDK=`pwd` T=x86_64-native-linuxapp-gcc DESTDIR=install 
popd
test -f /vagrant/v2.13.1.tar.gz || curl -L -o /vagrant/v2.13.1.tar.gz https://github.com/openvswitch/ovs/archive/v2.13.1.tar.gz
tar -xzvf /vagrant/v2.13.1.tar.gz
pushd ovs-2.13.1/
  yum install -y patch
  patch -p1 < /vagrant/virtio.patch
  ./boot.sh
  yum install -y python3-devel

  # static lib required newer version of pkgconfig so we use shared lib
  ./configure --prefix=/usr --localstatedir=/var --sysconfdir=/etc --with-dpdk=../dpdk-19.11/x86_64-native-linuxapp-gcc/
  make -j 32
  make install
  pushd rhel
    # setup ovs services
    cp etc_openvswitch_default.conf /etc/openvswitch/default.conf
    cp usr_lib_systemd_system_openvswitch.service /usr/lib/systemd/system/openvswitch.service
    cp usr_lib_systemd_system_ovsdb-server.service /usr/lib/systemd/system/ovsdb-server.service
    sed -i '/dpdk/d' usr_lib_systemd_system_ovs-vswitchd.service.in
    cp usr_lib_systemd_system_ovs-vswitchd.service.in /usr/lib/systemd/system/ovs-vswitchd.service
    cp usr_share_openvswitch_scripts_sysconfig.template /etc/sysconfig/openvswitch
    cp usr_lib_systemd_system_ovs-delete-transient-ports.service /usr/lib/systemd/system/ovs-delete-transient-ports.service
  popd
popd
systemctl daemon-reload
systemctl start openvswitch
ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-init=true
systemctl restart openvswitch

###########################################
######## add a dpdk port ##################
###########################################
curl -LO https://raw.githubusercontent.com/DPDK/dpdk/main/usertools/dpdk-devbind.py
chmod +x dpdk-devbind.py
modprobe uio_pci_generic
ip link set dev eth1 down
yum install -y pciutils
./dpdk-devbind.py -b uio_pci_generic 00:06.0
ovs-vsctl add-br br1 -- set bridge br1 datapath_type=netdev
ovs-vsctl add-port br1 dpdk1 -- set Interface dpdk1 type=dpdk options:dpdk-devargs=0000:00:06.0
