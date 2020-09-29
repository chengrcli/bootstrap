# reference: https://github.com/kubernetes-sigs/kubespray#quick-start
sudo apt update
sudo apt install -y python3-pip
git clone https://github.com/kubernetes-sigs/kubespray.git
pushd kubespray/
  sudo pip3 install -r requirements.txt
  cp -rfp inventory/sample inventory/mycluster

  # change-me
  # declare -a IPS=(192.168.121.158 192.168.121.159)
  CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
  # change-me
  # vi inventory/mycluster/group_vars/all/all.yml
  ansible-playbook -i inventory/mycluster/hosts.yaml  --become --become-user=root cluster.yml
popd
