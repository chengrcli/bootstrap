mkdir -p /media/iso
mount -o loop /vagrant/CentOS-7-x86_64-Everything-1810.iso /media/iso
cat > /etc/yum.repos.d/local.repo <<EOF
[local_server]
name=Thisis a local repo
baseurl=file:///media/iso
enabled=1
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
EOF
yum remove kernel-headers.x86_64
yum install -y "kernel-devel-uname-r == $(uname -r)"
yum install -y kernel-headers-`uname -r`
yum install -y yum-versionlock
yum versionlock kernel*
yum install -y numactl-devel libfdt-devel gcc git autoconf automake libtool python3 python3-devel python2-devel

tar -xzvf /vagrant/cmcc_ww22_release.tar.gz -C .
git clone https://github.com/DPDK/dpdk.git
pushd dpdk
  git checkout v19.11
  git apply ../cmcc_ww22_release/dpdk/vc_pacn3k_dpdk_ww22.patch
  git apply ../cmcc_ww22_release/dpdk/vc_pacn3k_dpdk_ww22_meter.patch
  git apply ../cmcc_ww22_release/dpdk/vc_pacn3k_dpdk_ww22_geneve.patch
  rm -rf ./build
  rm -rf x86_64-native-linuxapp-gcc
  make config RTE_SDK=`pwd` T=x86_64-native-linuxapp-gcc
  make -j 32 install RTE_SDK=`pwd` T=x86_64-native-linuxapp-gcc
popd
git clone https://github.com/openvswitch/ovs.git
pushd ovs
  git checkout v2.13.0
  git apply ../cmcc_ww22_release/ovs/vc_pacn3k_ovs_dpdk_APACHE-0.8.0.10.patch
  ./boot.sh
  ./configure --prefix=/usr --localstatedir=/var --sysconfdir=/etc --with-dpdk=../dpdk/x86_64-native-linuxapp-gcc/ CFLAGS='-O0 -g' LIBS='-lfdt'
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
  systemctl daemon-reload
  systemctl start openvswitch
popd
