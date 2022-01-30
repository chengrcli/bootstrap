set -ex

ovn-nbctl show
ovn-sbctl show
ovn-nbctl ls-add inside
ovn-nbctl ls-add dmz
ovn-nbctl show
ovn-nbctl lr-add tenant1
ovn-nbctl lrp-add tenant1 tenant1-dmz 02:ac:10:ff:01:29 172.16.255.129/26
ovn-nbctl lsp-add dmz dmz-tenant1
ovn-nbctl lsp-set-type dmz-tenant1 router
ovn-nbctl lsp-set-addresses dmz-tenant1 02:ac:10:ff:01:29
ovn-nbctl lsp-set-options dmz-tenant1 router-port=tenant1-dmz
ovn-nbctl lrp-add tenant1 tenant1-inside 02:ac:10:ff:01:93 172.16.255.193/26
ovn-nbctl lsp-add inside inside-tenant1
ovn-nbctl lsp-set-type inside-tenant1 router
ovn-nbctl lsp-set-addresses inside-tenant1 02:ac:10:ff:01:93
ovn-nbctl lsp-set-options inside-tenant1 router-port=tenant1-inside
ovn-nbctl show
ovn-nbctl lsp-add dmz dmz-vm1
ovn-nbctl lsp-set-addresses dmz-vm1 "02:ac:10:ff:01:30 172.16.255.130"
ovn-nbctl lsp-set-port-security dmz-vm1 "02:ac:10:ff:01:30 172.16.255.130"
ovn-nbctl lsp-add dmz dmz-vm2
ovn-nbctl lsp-set-addresses dmz-vm2 "02:ac:10:ff:01:31 172.16.255.131"
ovn-nbctl lsp-set-port-security dmz-vm2 "02:ac:10:ff:01:31 172.16.255.131"
ovn-nbctl lsp-add inside inside-vm3
ovn-nbctl lsp-set-addresses inside-vm3 "02:ac:10:ff:01:94 172.16.255.194"
ovn-nbctl lsp-set-port-security inside-vm3 "02:ac:10:ff:01:94 172.16.255.194"
ovn-nbctl lsp-add inside inside-vm4
ovn-nbctl lsp-set-addresses inside-vm4 "02:ac:10:ff:01:95 172.16.255.195"
ovn-nbctl lsp-set-port-security inside-vm4 "02:ac:10:ff:01:95 172.16.255.195"
ovn-nbctl show
dmzDhcp="$(ovn-nbctl create DHCP_Options cidr=172.16.255.128/26 \
options="\"server_id\"=\"172.16.255.129\" \"server_mac\"=\"02:ac:10:ff:01:29\" \
\"lease_time\"=\"3600\" \"router\"=\"172.16.255.129\"")"
echo $dmzDhcp
insideDhcp="$(ovn-nbctl create DHCP_Options cidr=172.16.255.192/26 \
options="\"server_id\"=\"172.16.255.193\" \"server_mac\"=\"02:ac:10:ff:01:93\" \
\"lease_time\"=\"3600\" \"router\"=\"172.16.255.193\"")"
echo $insideDhcp
ovn-nbctl dhcp-options-list
ovn-nbctl lsp-set-dhcpv4-options dmz-vm1 $dmzDhcp
ovn-nbctl lsp-get-dhcpv4-options dmz-vm1
ovn-nbctl lsp-set-dhcpv4-options dmz-vm2 $dmzDhcp
ovn-nbctl lsp-get-dhcpv4-options dmz-vm2
ovn-nbctl lsp-set-dhcpv4-options inside-vm3 $insideDhcp
ovn-nbctl lsp-get-dhcpv4-options inside-vm3
ovn-nbctl lsp-set-dhcpv4-options inside-vm4 $insideDhcp
ovn-nbctl lsp-get-dhcpv4-options inside-vm4
ovn-sbctl show


export chassis_uid=`ovn-sbctl find chassis hostname=ovn1 |grep -P "^name" | awk '{print $3}'`
ovn-nbctl create Logical_Router name=edge1 options:chassis=${chassis_uid}
ovn-nbctl ls-add transit
ovn-nbctl lrp-add edge1 edge1-transit 02:ac:10:ff:00:01 172.16.255.1/30
ovn-nbctl lsp-add transit transit-edge1
ovn-nbctl lsp-set-type transit-edge1 router
ovn-nbctl lsp-set-addresses transit-edge1 02:ac:10:ff:00:01
ovn-nbctl lsp-set-options transit-edge1 router-port=edge1-transit
ovn-nbctl lrp-add tenant1 tenant1-transit 02:ac:10:ff:00:02 172.16.255.2/30
ovn-nbctl lsp-add transit transit-tenant1
ovn-nbctl lsp-set-type transit-tenant1 router
ovn-nbctl lsp-set-addresses transit-tenant1 02:ac:10:ff:00:02
ovn-nbctl lsp-set-options transit-tenant1 router-port=tenant1-transit
ovn-nbctl lr-route-add edge1 "172.16.255.128/25" 172.16.255.2
ovn-nbctl lr-route-add tenant1 "0.0.0.0/0" 172.16.255.1
ovn-sbctl show

out_cidr=`ssh -o StrictHostKeyChecking=no ovn1 ip --brief a s eth2 | awk '{print $3}'`
ovn-nbctl lrp-add edge1 edge1-outside 02:0a:7f:00:01:29 $out_cidr
ovn-nbctl ls-add outside
ovn-nbctl lsp-add outside outside-edge1
ovn-nbctl lsp-set-type outside-edge1 router
ovn-nbctl lsp-set-addresses outside-edge1 02:0a:7f:00:01:29
ovn-nbctl lsp-set-options outside-edge1 router-port=edge1-outside
ovn-nbctl lsp-add outside outside-localnet
ovn-nbctl lsp-set-addresses outside-localnet unknown
ovn-nbctl lsp-set-type outside-localnet localnet
ovn-nbctl lsp-set-options outside-localnet network_name=dataNet

# add route for virual subnet
ip route add 172.16.255.128/25 via `echo $out_cidr |grep -oP "\d+\.\d+\.\d+\.\d+"`
