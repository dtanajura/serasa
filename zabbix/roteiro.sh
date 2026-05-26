kubectl config get-contexts
k config use-context arn:aws:eks:sa-east-1:146737708860:cluster/ds-eks-01-uat
kubectl create namespace zabbix
helm install zabbix-sre zabbix-community/zabbix --namespace zabbix
# NAME: zabbix-sre
# LAST DEPLOYED: Wed Jan 29 15:50:07 2025
# NAMESPACE: zabbix
# STATUS: deployed
# REVISION: 1
# NOTES:
# You can access Zabbix UI by establishing a port-forward with these commands:
#   export POD_NAME=$(kubectl get pods --namespace zabbix -l "app.kubernetes.io/name=zabbix,app.kubernetes.io/instance=zabbix-sre,app.kubernetes.io/component=web" -o jsonpath="{.items[0].metadata.name}")
#   export CONTAINER_PORT=$(kubectl get pod --namespace zabbix $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
#   kubectl --namespace zabbix port-forward $POD_NAME 8080:$CONTAINER_PORT
# Visit http://127.0.0.1:8080 to use your application
# Default credentials => Login: Admin Password: zabbix (Change after first access!!!)
k get gw -n monitoring-system grafana-gateway -o yaml
k get vs -n monitoring-system grafana-virtual-service -o yaml
# Ajustar arquivo gateway e vs nas seguintes linhas:
#   - hosts:
#     - zabbix.uat-ds.br.experian.eeca <= ajustar o domínio (tem duas entradas de hosts)
k create -f .\gateway.yaml
k create -f .\vs.yaml
