# setup openstack with openstack-ansible(osa)

The vagrantfile defines 3 nodes: `deployer`, `osa1`, `osa2`.

`deployer` is the VM which we install openstack-ansible on.
`osa1` and `osa2` are the VMs on which we install openstack.
**NOTE:** As osa doesn't support installing haproxy and os services
on the same node. We need at least two VMs for deployment.


## Virtual machine deployment steps

- Bring up the VMs
  ```bash
  vagrant up
  # Thia command brings up all the VMs. If you are deploying on baremetals,
  # we just need to bring up the deployer VM. So run "vagrant up deployer" instead
  ```

- Setup the `deployer` and run playbook to setup openstack. **NOTE:** For baremetal case, you need to manually do the steps in bootstrap.sh.
  ```bash
  vagrant ssh deployer
  sudo su -
  # flow the script /vagrant/setup-deployer-and-openstack.sh
  # to execute the commands in the script one by one
  # DO NOT execute the script directly, because you need to configur your proxy username/password manually
  ```

- As with the previous steps finished, the openstack deployment is finished.
haproxy is installed on `osa1`, openstack services are install on `osa2`

- Now we can login `osa1` to launch VMs by following `launch_instance.sh`

- To add more computes nodes, add the new comupte nodes under `compute-infra_hosts` and `compute_hosts` in `etc/openstack_deploy/openstack_user_config.yml`.
Then run playbook again. Needs to remove `/etc/openstack_deploy/openstack_inventory.json` before running playbook

## Physical machine deployment steps

Please first read the virtual machine deployment steps.

- setup deployer host and openstack by following `setup-deployer-and-openstack.sh`
- To add more computes nodes, add the nodes under `compute-infra_hosts` and `compute_hosts` in `etc/openstack_deploy/openstack_user_config.yml`.
Then run playbook again. Needs to remove `/etc/openstack_deploy/openstack_inventory.json` before running playbook


## Trouble shooting

If nova-compute fails to start, we can check `libvirt-python` version within nova virtualenv.
version 6.7.0 is the bad version, downgrade it to 6.1.0
