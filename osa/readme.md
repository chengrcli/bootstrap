# setup openstack with openstack-ansible(osa)

The vagrantfile defines 3 nodes: `deployer`, `osa1`, `osa2`.

`deployer` is the VM which we install openstack-ansible on.
`osa1` and `osa2` are the VMs on which we install openstack.
**NOTE:** As osa doesn't support installing haproxy and os services
on the same node. We need at least two VMs for openstack.


## deploy steps

- Bring up the VMs
  ```
  vagrant up
  ```

- Setup the `deployer` and run playbook to setup openstack. **NOTE:** For baremetal case, you need to manually do the steps in bootstrap.sh.
  ```
  vagrant ssh deployer
  sudo su -
  # flow the script /vagrant/setup-deployer-and-openstack.sh
  # to execute the commands in the script one by one
  # DO NOT execute the script directly, because you need to configur your proxy username/password manually
  ```

- As with the previous steps finished, the openstack deployment is finished.
haproxy is installed on `osa1`, openstack services are install on `osa2`

- Now we can login `osa1` to launch VMs by following `launch_instance.sh`
