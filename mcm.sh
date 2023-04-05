# Install helm first!!!

export PATH=$PATH:/var/lib/rancher/rke2/bin:/usr/local/bin/:$PATH
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
export CRI_CONFIG_FILE=/var/lib/rancher/rke3/agent/etc/crictl.yaml

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
sudo ./get_helm.sh


# Install Rancher Cluster Manager
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest

kubectl create namespace cattle-system

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.7.1/cert-manager.crds.yaml

helm repo add jetstack https://charts.jetstack.io

helm repo update

helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.7.1

helm install rancher rancher-latest/rancher \
  --namespace cattle-system \
  --set hostname=rancher.billylieberman.com \
  --set replicas=1 \
  --set bootstrapPassword=P@ssw0rd