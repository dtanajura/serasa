#######################################
######## apigee-microgateway
#######################################
# Manter as configurações atuais
$pack = "apigee-microgateway"
$namespace = "apigee-system"
mkdir "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack"
helm get values $pack -n $namespace > "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml"
notepad.exe "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml"

kubectl get all -n apigee-system
<#
NAME                                                     READY   STATUS    RESTARTS   AGE
pod/eks-nike-tech-01-prod-microgateway-b4c54cb87-4fnrc   1/1     Running   0          34d

NAME                                                 TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
service/eks-nike-tech-01-prod-microgateway-service   NodePort   172.20.47.137   <none>        8000:30449/TCP   2y176d

NAME                                                 READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/eks-nike-tech-01-prod-microgateway   1/1     1            1           2y176d

NAME                                                            DESIRED   CURRENT   READY   AGE
replicaset.apps/eks-nike-tech-01-prod-microgateway-67f67f7bfb   0         0         0       2y176d
replicaset.apps/eks-nike-tech-01-prod-microgateway-84fb6c8dc9   0         0         0       2y176d
replicaset.apps/eks-nike-tech-01-prod-microgateway-9d6b7cf66    0         0         0       2y176d
replicaset.apps/eks-nike-tech-01-prod-microgateway-b4c54cb87    1         1         1       501d
replicaset.apps/eks-nike-tech-01-prod-microgateway-ddb785cf8    0         0         0       2y176d
#>

# Atualizar
helm upgrade apigee-microgateway oci://us-docker.pkg.dev/apigee-release/apigee-hybrid-helm-charts/apigee-microgateway `
  --namespace apigee-system `
  -f  "C:\tmp\gitops-eks-mgmt\clusters\564593125549-eec-aws-br-nike-corporate-prod\$pack\values.yaml" 

