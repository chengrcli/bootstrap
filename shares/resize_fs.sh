set -ex

# extend the disk partition and file systemd
disk='vda'
if [ -f /dev/sda ]
then
  disk='sda'
fi
sudo parted -a optimal /dev/$disk ---pretend-input-tty resizepart 3 yes 100%
sudo resize2fs /dev/${disk}3
