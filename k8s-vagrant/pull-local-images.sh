pr=10.239.12.37:5000
for image in `awk '{if ($1 !~ /^\s*$/) {if ($1 ~ /\.io|\.com|\.org/) {print $1} else {print "docker.io/"$1} }}' /vagrant/k8s-image.list`
do
  docker pull $pr/${image#*/}
done
