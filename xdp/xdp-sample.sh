sudo apt update
sudo apt install -y clang llvm make gcc-multilib libelf-dev libssl-dev bison flex
tag=`uname -r |grep -oP '\d+\.\d+'`
wget --continue https://github.com/torvalds/linux/archive/v${tag}.zip
unzip v${tag}.zip
cd linux-$tag
make -C tools clean
make -C samples/bpf clean
make clean
make defconfig
make headers_install
make samples/bpf/
curl https://help.netronome.com/helpdesk/attachments/36025601060 -L -o ~/bpftool.deb
sudo dpkg -i ~/bpftool.deb
