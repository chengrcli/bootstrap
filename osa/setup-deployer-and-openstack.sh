yum install -y git ntp ntpdate openssh-server python-devel sudo '@Development Tools'
yum install -y bind-utils
cd /opt
git clone https://github.intel.com/chengli3/openstack-ansible.git
cd openstack-ansible
scripts/bootstrap-ansible.sh
osa1_ip=`host osa1 |grep "has address" | awk '{print $4}'`
osa2_ip=`host osa2 |grep "has address" | awk '{print $4}'`
osa2_eth1_ip=`ssh -o StrictHostKeyChecking=no osa2 "ip -4 addr show eth1 | grep -oP '(?<=inet ).*(?=/)'"`
sed -i "s/osa1_ip/$osa1_ip/g" etc/openstack_deploy/openstack_user_config.yml
sed -i "s/osa2_ip/$osa2_ip/g" etc/openstack_deploy/openstack_user_config.yml
sed -i "s/osa2_eth1_ip/$osa2_eth1_ip/g" etc/openstack_deploy/openstack_user_config.yml
# Before running the next steps, you need to set the proxy username/password
# in etc/openstack_deploy/user_variables.yml (search "proxy_env_url")
cp -r /opt/openstack-ansible/etc/openstack_deploy /etc/
cd playbooks
openstack-ansible setup-hosts.yml
openstack-ansible setup-infrastructure.yml
openstack-ansible setup-openstack.yml
