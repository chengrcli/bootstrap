set -e
OVS_VERSION=master
WITH_DPDK=no
WITH_AFXDP=no
bootstrap=no
while getopts ":O:D:P:dxbv" opt; do
  case ${opt} in
    D )
      DPDK_VERSION=$OPTARG
      WITH_DPDK=yes
      ;;
    O )
      OVS_VERSION=$OPTARG
      if [ "$OVS_VERSION" \< "2.13" ];then
         echo "ovs version must be >= 2.13"
         exit 1
      fi
      ;;
    P )
      export https_proxy=$OPTARG http_proxy=$OPTARG
      ;;
    d )
      WITH_DPDK=yes
      ;;
    x )
      WITH_AFXDP=yes
      ;;
    b ) bootstrap=yes
      ;;
    v ) set -x
      ;;
    \? ) echo "Usage: cmd 
              [-O xx] # ovs version
              [-P xx] # use http proxy
              [-d] # build with dpdk enabled
              [-x] # build with af_xdp enabled
              [-b] # bootstrap with ovs ports
              [-v] # verbose"
         exit 1
      ;;
  esac
done

case $OVS_VERSION in
  2.13.*|2.14.* )
    DPDK_VERSION=19.11
    ;;
  2.15.*|2.16.* )
    DPDK_VERSION=20.11
    ;;
  2.17.*|master )
    DPDK_VERSION=21.11
    ;;
esac

yum install -y git

#####################
#### setup dpdk #####
#####################
if [  "$WITH_DPDK" == "yes" ]
then
  if [ "$DPDK_VERSION" == "master" ]
  then
    TAG=master
  else
    TAG=v$DPDK_VERSION
  fi
  git clone --depth=1 -b $TAG https://github.com/DPDK/dpdk.git
  pushd dpdk
    yum install -y python3-pip numactl-devel
    pip3 install meson ninja pyelftools
    meson --prefix /usr build
    ninja -C build
    ninja -C build install
    ldconfig
    pkg-config --modversion libdpdk
  popd
fi

#####################
#### setup libbpf ###
#####################
if [  "$WITH_AFXDP" == "yes" ]
then
  yum install -y gcc ncurses-devel elfutils-libelf-devel bc openssl-devel libcap-devel clang llvm graphviz bison flex
  git clone --depth=1 https://github.com/libbpf/libbpf.git
  pushd libbpf/src
    make
    make install
    ldconfig -p | grep libbpf
  popd
fi


####################
#### setup ovs #####
####################
if [ "$OVS_VERSION" == "master" ]
then
  TAG=master
else
  TAG=v$OVS_VERSION
fi
git clone --depth=1 -b $TAG https://github.com/openvswitch/ovs.git
pushd ovs
  yum install -y python3-devel numactl-devel elfutils-libelf-devel
  ./boot.sh
  # upgrade pkgconfig if DPDK Version is 20.11
  # old version may be installed as dependency in future
  if [ "$DPDK_VERSION" \> "19.11" ] && [ `pkg-config --version` \< "0.29" ]
  then
    test -f /vagrant/pkg-config-0.29.1.tar.gz || curl -L https://pkg-config.freedesktop.org/releases/pkg-config-0.29.1.tar.gz -o /vagrant/pkg-config-0.29.1.tar.gz
    tar -xzvf /vagrant/pkg-config-0.29.1.tar.gz -C ..
    pushd ../pkg-config-0.29.1/
      rpm -e --nodeps pkgconfig
      ./configure --prefix /usr --with-internal-glib
      make
      make install
      # self built pkg-config doesnt look for /usr/lib64 by default, so specifiy it
      export PKG_CONFIG_PATH=/usr/lib64/pkgconfig
    popd
  fi

  OPTS=""
  if [ "$WITH_DPDK" == "yes" ]
  then
    OPTS="$OPTS --with-dpdk=yes"
  fi
  if [ "$WITH_AFXDP" == "yes" ]
  then
    OPTS="$OPTS --enable-afxdp"
  fi
  ./configure --prefix=/usr --localstatedir=/var --sysconfdir=/etc $OPTS
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
if [ "$WITH_DPDK" == "yes" ]
then
  ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-init=true
fi
systemctl restart openvswitch

###########################################
######## add ports ########################
###########################################
if [ "$bootstrap" == "yes" ]
then
  ovs-vsctl add-br br1 -- set bridge br1 datapath_type=netdev
  if [ "$WITH_DPDK" == "yes" ]
  then
    # we use driverctl instead of the old dpdk-devbind way
    yum install -y driverctl
    eth1_bdf=`ethtool -i eth1 |grep bus-info | awk '{print $2}'`
    driverctl set-override $eth1_bdf uio_pci_generic
    ovs-vsctl add-port br1 dpdketh1 -- set Interface dpdketh1 type=dpdk options:dpdk-devargs=$eth1_bdf
  fi
  if [ "$WITH_DPDK" == "yes" ]
  then
    ovs-vsctl add-port br1 eth2 -- set Interface eth2 type="afxdp" options:xdp-mode=generic
  fi
fi
