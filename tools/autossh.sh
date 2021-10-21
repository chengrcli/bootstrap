set -ex

yum install -y autossh
cat > /etc/autossh/pubforward.sh <<EOF
OPTIONS=-M 0 -N -R "*:9922:127.0.0.1:22" -o StrictHostKeyChecking=no -o ExitOnForwardFailure=yes outer
EOF
