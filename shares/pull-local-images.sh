pr=chengdev2.sh.intel.com:5000
for image in `awk '{if ($1 !~ /^\s*$/) {if ($1 ~ /\.io|\.com|\.org/) {print $1} else {print "docker.io/"$1} }}' /vagrant/single-image.list`
do
  if [[ $image =~ ^docker.io/* ]]; then
    echo "skip $image"
  else
    docker pull $pr/${image#*/}
  fi
done

