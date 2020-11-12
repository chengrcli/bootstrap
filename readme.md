# practice vagrant

This repo has some vagrants to set virtual machines for practice purpose.
- ubuntu16
- ubuntu18
- centos7
- k8s
- ovn
- ovs_afxdp

## Setup vagrant and libvirt

CentOS 7 and ubuntu 18.04 are tested as host

```bash
git clone https://github.com/chengrcli/bootstrap.git
bash bootstrap/setup_vagrant.sh
```

## Launch the virtual machines

For most of the practices, it's as easy as `vagrant up` in the sub directory.
Some practice may need extra steps, the steps are listed in the sub directory readme file.

```bash
cd bootstrap/ubuntu16
vagrant up
```
