if [ -z "$1" ]
then
  echo "Usage: $0 <netid>"
  exit 1
fi
netid=$1

cat > /tmp/virtnet-tmp.xml <<EOF
<network ipv6='yes'>
  <name>private-${netid}</name>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='virbr_${netid}' stp='on' delay='0'/>
  <ip address='192.168.${netid}.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.${netid}.1' end='192.168.${netid}.254'/>
    </dhcp>
  </ip>
</network>
EOF

virsh net-define /tmp/virtnet-tmp.xml
virsh net-start private-$netid
