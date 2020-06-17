yum install -y git ntp ntpdate openssh-server python-devel sudo '@Development Tools'
yum install -y bind-utils
git clone -b 21.0.0.0rc1 https://opendev.org/openstack/openstack-ansible /opt/openstack-ansible
cd /opt/openstack-ansible
git checkout -b ussuri 21.0.0.0rc1
git config user.email "cheng1.li@intel.com"
git am /vagrant/Two-nodes-deployment-with-ovs-dpdk.patch
scripts/bootstrap-ansible.sh
pushd /etc/ansible/roles/os_neutron/
  git apply /vagrant/neutron_dpdk.diff
popd
# For baremeatl case, please to set the ip and phynet1_if accordin to the BM info
osa1_ip=`host osa1 |grep "has address" | awk '{print $4}'`
osa2_ip=`host osa2 |grep "has address" | awk '{print $4}'`
phynet1_if=eth1
sed -i "s/osa1_ip/$osa1_ip/g" etc/openstack_deploy/openstack_user_config.yml
sed -i "s/osa2_ip/$osa2_ip/g" etc/openstack_deploy/openstack_user_config.yml
sed -i "s/phynet1_if/$phynet1_if/g" etc/openstack_deploy/openstack_user_config.yml
# Before running the next steps, you need to set the proxy username/password
# in etc/openstack_deploy/user_variables.yml (search "proxy_env_url")
cp -r /opt/openstack-ansible/etc/openstack_deploy /etc/
cd playbooks
openstack-ansible setup-hosts.yml
openstack-ansible setup-infrastructure.yml
openstack-ansible setup-openstack.yml
