# practice vagrant

This repo has some vagrants to set virtual machines for practice purpose.
- ubuntu16
- ubuntu18
- centos7
- k8s
- ovn
- ovs_afxdp

## Setup vagrant and libvirt

CentOS 7 are tested as host

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
## How to create a box

- provide your ISO file for new box and then edit isovm/Vagrantfile to boot VM from ISO
- connect VM via vnc console and install OS
- configure before shutdown VM:
    - create `vagrant` user
    - grant `vagrant` user sudo permission without password
    - insert **insecure** ssh key for vagrant user so that vagrant can connect
    - enable ssh login
    - remove machine-id mark so that every VM instance send dhcp request with differnt client-id, to get different ip address. `echo -n > /etc/machine-id`
    - enable console:
        - Edit the /etc/default/grub file and configure the GRUB_CMDLINE_LINUX option. Delete the rhgb quiet and add console=tty0 console=ttyS0,115200n8 to the option.
        - Run `grub2-mkconfig -o /boot/grub2/grub.cfg` to save changes
    - install `rsync`
- shutdown VM then we get the qcow2 img `ivmdisk.img`, need to rename it to name `box.img`
- create metadata.json
    ```json
    {
        "provider": "libvirt",
        "format": "qcow2",
        "virtual_size": 40
    }
    ```
- create Vagrantfile
    ```ruby
    Vagrant.configure("2") do |config|
    # If the OS type is not registried in vagrant libvirt provider,
    # we can mark it as a well known OS type, i.e. centos, so that provider can configure VM in centos way
    config.vm.guest = "centos"
    config.vm.provider :libvirt do |v, override|
        v.disk_bus = "virtio"
        v.host = ""
        v.connect_via_ssh = false
        # v.storage_pool_name = "default"
        v.driver = "kvm"
        v.video_vram = 256
        v.memory = 2048
        v.cpus = 2
    end
    end
    ```
- tar the box file. `tar cvzf custom_box.box ./metadata.json ./Vagrantfile ./box.img`

## References

- https://github.com/vagrant-libvirt/vagrant-libvirt
- https://docs.openstack.org/image-guide/centos-image.html
- https://blog.programster.org/qemu-img-cheatsheet
- https://octetz.com/docs/2020/2020-10-19-machine-images/
