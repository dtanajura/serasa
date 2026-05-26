########################
# aws-efs-csi-driver
########################
helm repo add aws-efs-csi-driver https://kubernetes-sigs.github.io/aws-efs-csi-driver/
helm search repo aws-efs-csi-driver
<#
NAME                                    CHART VERSION   APP VERSION     DESCRIPTION
aws-efs-csi-driver/aws-efs-csi-driver   3.2.3           2.1.12          A Helm chart for AWS EFS CSI Driver
#>

kubectl get all -n kube-system | Select-String "efs"
<#
pod/efs-csi-controller-6f75577dbb-wdqm2                         3/3     Running   0          34d
pod/efs-csi-controller-6f75577dbb-zk9xk                         3/3     Running   0          34d
pod/efs-csi-node-4c5xj                                          3/3     Running   0          34d
pod/efs-csi-node-7sdpw                                          3/3     Running   0          34d
pod/efs-csi-node-r94wj                                          3/3     Running   0          34d
daemonset.apps/efs-csi-node           3         3         3       3            3           kubernetes.io/os=linux     2y176d
deployment.apps/efs-csi-controller                          2/2     2            2           2y176d
replicaset.apps/efs-csi-controller-6f75577dbb                          2         2         2       2y176d
#>
helm repo update
mkdir "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\aws-efs-csi-driver"
helm get values aws-efs-csi-driver -n kube-system > "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\aws-efs-csi-driver\values.yaml"
# No arquivo de values comentar campos de image e sidecar

helm upgrade aws-efs-csi-driver aws-efs-csi-driver/aws-efs-csi-driver `
  --namespace kube-system `
  --values "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\aws-efs-csi-driver\values.yaml"

## Confirmação da atualização
# aws-efs-csi-driver  kube-system  1  2023-04-13 20:09:08.009485647 -0300 -03 deployed  aws-efs-csi-driver-2.4.1  1.5.4
