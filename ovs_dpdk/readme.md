# setup ovsdpdk from source code

1. bring up VM with `vagrant up`
1. compile ovs dpdk
```bash
# first login VM
bash /vagrant/setup_ovsdpdk.sh -o master -b -v
```

## references

- https://docs.openvswitch.org/en/latest/intro/install/general/
- https://docs.openvswitch.org/en/latest/intro/install/dpdk/
