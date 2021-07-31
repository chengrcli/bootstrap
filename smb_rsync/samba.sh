set -ex
sudo yum install -y samba samba-client cifs-utils
sudo mkdir -p /samba/pub
sudo chown -R nobody:nobody /samba/pub
sudo cp /vagrant/smb.conf /etc/samba/smb.conf
sudo systemctl restart smb nmb
sudo cp /vagrant/rsync.sh /etc/cron.daily/

# add user
sudo groupadd sambashare
sudo mkdir -p /samba/cheng
sudo chgrp sambashare /samba/cheng/
sudo useradd -M  -s /usr/sbin/nologin -G sambashare cheng
sudo chown cheng:sambashare /samba/cheng/
smbpasswd -a cheng
smbpasswd -e cheng

# to mount smb
# mount -t cifs //127.0.0.1/pub /mnt
# mount -t cifs -o username=cheng //127.0.0.1/cheng /mnt
