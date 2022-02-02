set -e
OVS_VERSION=2.13.1
bootstrap=0
while getopts ":o:d:l:bv" opt; do
  case ${opt} in
    d )
      DPDK_VERSION=$OPTARG
      ;;
    o )
      OVS_VERSION=$OPTARG
      ;;
    b ) bootstrap=1
      ;;
    v ) set -x
      ;;
    \? ) echo "Usage: cmd 
              [-o] # ovs version
              [-b] # bootstrap ovs bridge and port
              [-v] # verbose"
         exit 1
      ;;
  esac
done

# export https_proxy=192.168.121.1:1080 http_proxy=192.168.121.1:1080
case $OVS_VERSION in
  2.13.1 | 2.14.0 )
    DPDK_VERSION=19.11
    ovs_packet_file=v${OVS_VERSION}.tar.gz
    ;;
  master )
    DPDK_VERSION=21.11
    ovs_packet_file=${OVS_VERSION}.tar.gz
    ;;
esac
ovs_packet_url="https://github.com/openvswitch/ovs/archive/$ovs_packet_file"
ovs_dir=ovs-$OVS_VERSION

dpdk_packet_file=v${DPDK_VERSION}.tar.gz
dpdk_packet_url="https://github.com/DPDK/dpdk/archive/$dpdk_packet_file"
dpdk_dir=dpdk-$DPDK_VERSION

#####################
#### setup dpdk #####
#####################
test -f /vagrant/$dpdk_packet_file || curl -L -o /vagrant/$dpdk_packet_file $dpdk_packet_url
tar -xzvf /vagrant/$dpdk_packet_file
pushd $dpdk_dir
  yum install -y meson  numactl-devel
  meson --prefix /usr build
  ninja -C build
  ninja -C build install
  ldconfig
popd


####################
#### setup ovs #####
####################
test -f /vagrant/$ovs_packet_file || curl -L -o /vagrant/$ovs_packet_file $ovs_packet_url
tar -xzvf /vagrant/$ovs_packet_file
pushd $ovs_dir
  yum install -y python3-devel
  # apply virtio patch for non-master branch
  if [ "$OVS_VERSION" != "master" ]
  then
    yum install -y patch
    patch -p1 < /vagrant/virtio.patch
  fi

  ./boot.sh
  # upgrade pkgconfig if DPDK Version is 20.11
  # old version may be installed as dependency in future
  if [ "$DPDK_VERSION" == "20.11" ]
  then
    test -f /vagrant/pkg-config-0.29.1.tar.gz || curl -L https://pkg-config.freedesktop.org/releases/pkg-config-0.29.1.tar.gz -o /vagrant/pkg-config-0.29.1.tar.gz
    tar -xzvf /vagrant/pkg-config-0.29.1.tar.gz -C ..
    pushd ../pkg-config-0.29.1/
      rpm -e --nodeps pkgconfig
      ./configure --prefix /usr --with-internal-glib
      make
      make install
      # self built pkg-config doesn't look for /usr/lib64 by default, so specifiy it
      export PKG_CONFIG_PATH=/usr/lib64/pkgconfig
    popd
  fi

  ./configure --prefix=/usr --localstatedir=/var --sysconfdir=/etc --with-dpdk=yes
  make -j 32
  make install
  pushd rhel
    # setup ovs services
    cp -f etc_openvswitch_default.conf /etc/openvswitch/default.conf
    cp -f usr_lib_systemd_system_openvswitch.service /usr/lib/systemd/system/openvswitch.service
    cp -f usr_lib_systemd_system_ovsdb-server.service /usr/lib/systemd/system/ovsdb-server.service
    sed -i '/dpdk/d' usr_lib_systemd_system_ovs-vswitchd.service.in
    cp -f usr_lib_systemd_system_ovs-vswitchd.service.in /usr/lib/systemd/system/ovs-vswitchd.service
    cp -f usr_share_openvswitch_scripts_sysconfig.template /etc/sysconfig/openvswitch
    cp -f usr_lib_systemd_system_ovs-delete-transient-ports.service /usr/lib/systemd/system/ovs-delete-transient-ports.service
  popd
popd
systemctl daemon-reload
systemctl start openvswitch
ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-init=true
systemctl restart openvswitch

###########################################
######## add a dpdk port ##################
###########################################
if [ "$bootstrap" -gt 0 ]
then
  # we use driverctl instead of the old dpdk-devbind way
  yum install -y driverctl
  driverctl set-override 0000:00:06.0 uio_pci_generic
  ovs-vsctl add-br br1 -- set bridge br1 datapath_type=netdev
  ovs-vsctl add-port br1 dpdk1 -- set Interface dpdk1 type=dpdk options:dpdk-devargs=0000:00:06.0
fi
