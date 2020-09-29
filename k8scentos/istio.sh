# script reference: https://istio.io/latest/docs/setup/getting-started/
# run this script as user vagrant
set -e
sudo chmod 666 /etc/kubernetes/admin.conf
set +e
# genearte the ~/.kube directory
kubectl get pod 
set -e
cp /etc/kubernetes/admin.conf ~/.kube/config
curl -L https://istio.io/downloadIstio | sh -
pushd istio-1.*/
  export PATH=$PWD/bin:$PATH
  istioctl install --set profile=demo
  kubectl label namespace default istio-injection=enabled
  kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
popd
