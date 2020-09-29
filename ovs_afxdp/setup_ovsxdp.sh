sudo apt update
curl http://ftp.cn.debian.org/debian/pool/main/libb/libbpf/libbpf0_0.1.0-1_amd64.deb -LO
curl http://ftp.cn.debian.org/debian/pool/main/libb/libbpf/libbpf-dev_0.1.0-1_amd64.deb -LO
sudo dpkg -i libbpf0_0.1.0-1_amd64.deb
sudo dpkg -i libbpf-dev_0.1.0-1_amd64.deb
dpkg -l |grep libbpf
ldconfig -p | grep libbpf
test -f /vagrant/ovs-2.13.zip || curl -L -o /vagrant/ovs-2.13.zip  https://github.com/openvswitch/ovs/archive/v2.13.0.zip
unzip /vagrant/ovs-2.13.zip
pushd ovs-2.13.0
  export OVS_SOURCE=`pwd`
  sudo apt install -y openssl autoconf automake libssl-dev libtool
  sudo apt install -y libnuma-dev 
  ./boot.sh
  ./configure --enable-afxdp --prefix=/usr --localstatedir=/var --sysconfdir=/etc --disable-dependency-tracking
  sudo apt install -y make build-essential libelf-dev
  make
  sudo make install
  export PATH=$PATH:/usr/share/openvswitch/scripts
  ovs-ctl --no-ovs-vswitchd --system-id=random start
  ovs-ctl --no-ovsdb-server start
popd

#ethtool -K p1 rx off tx off
