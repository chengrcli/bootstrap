sudo apt update
sudo apt install -y ovn-central openvswitch-switch
sudo ovn-sbctl set-connection ptcp:6642
sudo ovn-nbctl set-connection ptcp:6641
