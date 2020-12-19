set -ex
sudo yum install -y samba samba-client cifs-utils
sudo mkdir -p /samba/share
sudo chown -R nobody:nobody /samba/share
sudo cp /vagrant/smb.conf /etc/samba/smb.conf
sudo systemctl restart smb nmb
sudo cp /vagrant/rsync.sh /etc/cron.daily/

# to mount smb
# mount -t cifs //127.0.0.1/share /mnt/share
