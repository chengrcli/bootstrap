# reference: https://github.com/kubernetes-sigs/kubespray#quick-start
which apt && (
  sudo apt update
  sudo apt install -y python3-pip git
  ) || sudo yum install -y python3-pip git
git clone https://github.com/kubernetes-sigs/kubespray.git
pushd kubespray/
  sudo pip3 install -r requirements.txt
  cp -rfp inventory/sample inventory/mycluster

  # change-me
  kub1_ip=`host kub1 |grep "has address" | awk '{print $4}'`
  kub2_ip=`host kub2 |grep "has address" | awk '{print $4}'`
  declare -a IPS=($kub1_ip $kub2_ip)
  CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
  # change-me
  # vi inventory/mycluster/group_vars/all/all.yml
  ansible-playbook -i inventory/mycluster/hosts.yaml  --become --become-user=root cluster.yml
popd
