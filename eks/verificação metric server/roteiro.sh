k config use-context arn:aws:eks:sa-east-1:087086536124:cluster/ssrm-eks-01-sandbox
k get pod -n kube-system
# metrics-server-546db89c8d-kzshg                              1/1     Running   0          15d
k log metrics-server-546db89c8d-kzshg -n kube-system
# E1125 22:51:33.293582       1 scraper.go:149] "Failed to scrape node" err="Get \"https://10.99.144.54:10250/metrics/resource\": dial tcp 10.99.144.54:10250: connect: connection refused" node="ip-10-99-144-54.sa-east-1.compute.internal"
# E1125 22:51:58.294136       1 scraper.go:147] "Failed to scrape node, timeout to access kubelet" err="Get \"https://10.99.144.54:10250/metrics/resource\": context deadline exceeded" node="ip-10-99-144-54.sa-east-1.compute.internal" timeout="10s"
# E1125 22:52:33.351772       1 scraper.go:149] "Failed to scrape node" err="Get \"https://10.99.144.117:10250/metrics/resource\": dial tcp 10.99.144.117:10250: connect: connection refused" node="ip-10-99-144-117.sa-east-1.compute.internal"
# E1125 22:54:13.275191       1 scraper.go:147] "Failed to scrape node, timeout to access kubelet" err="Get \"https://10.99.144.117:10250/metrics/resource\": context deadline exceeded" node="ip-10-99-144-117.sa-east-1.compute.internal" timeout="10s"
# E1125 22:56:48.329352       1 scraper.go:149] "Failed to scrape node" err="Get \"https://10.99.144.159:10250/metrics/resource\": dial tcp 10.99.144.159:10250: connect: connection refused" node="ip-10-99-144-159.sa-east-1.compute.internal"
# E1125 22:59:18.317487       1 scraper.go:149] "Failed to scrape node" err="Get \"https://10.99.144.6:10250/metrics/resource\": remote error: tls: internal error" node="ip-10-99-144-6.sa-east-1.compute.internal"
# E1125 23:03:13.355604       1 scraper.go:147] "Failed to scrape node, timeout to access kubelet" err="Get \"https://10.99.144.6:10250/metrics/resource\": context deadline exceeded" node="ip-10-99-144-6.sa-east-1.compute.internal" timeout="10s"

k get nodes -o wide
# NAME                                          STATUS   ROLES    AGE   VERSION               INTERNAL-IP     EXTERNAL-IP   OS-IMAGE         KERNEL-VERSION                  CONTAINER-RUNTIME
# ip-10-99-144-104.sa-east-1.compute.internal   Ready    <none>   15d   v1.30.6-eks-94953ac   10.99.144.104   <none>        Amazon Linux 2   5.10.227-219.884.amzn2.x86_64   containerd://1.7.22
# ip-10-99-144-111.sa-east-1.compute.internal   Ready    <none>   15d   v1.30.6-eks-94953ac   10.99.144.111   <none>        Amazon Linux 2   5.10.227-219.884.amzn2.x86_64   containerd://1.7.22
# ip-10-99-144-137.sa-east-1.compute.internal   Ready    <none>   15d   v1.30.6-eks-94953ac   10.99.144.137   <none>        Amazon Linux 2   5.10.227-219.884.amzn2.x86_64   containerd://1.7.22
# ip-10-99-144-155.sa-east-1.compute.internal   Ready    <none>   15d   v1.30.6-eks-94953ac   10.99.144.155   <none>        Amazon Linux 2   5.10.227-219.884.amzn2.x86_64   containerd://1.7.22
# ip-10-99-144-177.sa-east-1.compute.internal   Ready    <none>   15d   v1.30.6-eks-94953ac   10.99.144.177   <none>        Amazon Linux 2   5.10.227-219.884.amzn2.x86_64   containerd://1.7.22
# ip-10-99-144-18.sa-east-1.compute.internal    Ready    <none>   15d   v1.30.6-eks-94953ac   10.99.144.18    <none>        Amazon Linux 2   5.10.227-219.884.amzn2.x86_64   containerd://1.7.22
# ip-10-99-144-23.sa-east-1.compute.internal    Ready    <none>   15d   v1.30.6-eks-94953ac   10.99.144.23    <none>        Amazon Linux 2   5.10.227-219.884.amzn2.x86_64   containerd://1.7.22
# ip-10-99-144-26.sa-east-1.compute.internal    Ready    <none>   15d   v1.30.6-eks-94953ac   10.99.144.26    <none>        Amazon Linux 2   5.10.227-219.884.amzn2.x86_64   containerd://1.7.22
# ip-10-99-144-5.sa-east-1.compute.internal     Ready    <none>   15d   v1.30.6-eks-94953ac   10.99.144.5     <none>        Amazon Linux 2   5.10.227-219.884.amzn2.x86_64   containerd://1.7.22
# ip-10-99-144-71.sa-east-1.compute.internal    Ready    <none>   15d   v1.30.6-eks-94953ac   10.99.144.71    <none>        Amazon Linux 2   5.10.227-219.884.amzn2.x86_64   containerd://1.7.22

kubectl exec -it metrics-server-546db89c8d-kzshg  -n kube-system -- ping 10.99.144.104
kubectl exec -it ubuntu-pod -- curl -k https://10.99.144.104:10250/metrics/resource
# Unauthorized
k describe pod metrics-server-546db89c8d-kzshg -n kube-system
# ...
# Service Account:      metrics-server

aws eks describe-cluster --name ssrm-eks-01-sandbox --query "cluster.resourcesVpcConfig.securityGroupIds" --profile ssrmsandbox
# [
#     "sg-0743194f8e960c08a"
# ]
aws ec2 describe-security-groups --group-ids sg-0743194f8e960c08a --profile ssrmsandbox
aws ec2 authorize-security-group-ingress --group-id sg-0743194f8e960c08a --protocol tcp --port 10250 --cidr 10.0.0.0/8 --profile ssrmsandbox
