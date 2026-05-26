k config use-context arn:aws:eks:sa-east-1:087086536124:cluster/ssrm-eks-01-sandbox
k create namespace pinot
namespace/pinot created
kubectl annotate namespace pinot meta.helm.sh/release-name=pinot
kubectl annotate namespace pinot meta.helm.sh/release-namespace=pinot
kubectl label namespace pinot app.kubernetes.io/managed-by=Helm
helm install pinot pinot/pinot -n pinot --set cluster.name=pinot-ssrm-sandbox --set server.replicaCount=2
# NAME: pinot
# LAST DEPLOYED: Thu Jan 30 10:55:58 2025
# NAMESPACE: pinot
# STATUS: deployed
# REVISION: 1
# TEST SUITE: None
k config set-context --current --namespace=pinot
