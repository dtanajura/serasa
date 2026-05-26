aws kafka describe-cluster --cluster-arn arn:aws:kafka:sa-east-1:662860092544:cluster/ds-msk-prod/90e49179-2238-4ac2-8de1-29e44d56c731-3 --profile dsprod --query "ClusterInfo.CurrentVersion"
# "K1SV63LBFD2XEJ"

aws kafka update-broker-count `
    --cluster-arn arn:aws:kafka:sa-east-1:662860092544:cluster/ds-msk-prod/90e49179-2238-4ac2-8de1-29e44d56c731-3 `
    --current-version K1JMRNFQWME36Y `
    --target-number-of-broker-nodes 21 `
    --profile dsprod

## Dar acesso ao session manager na role BURoleForSREAutomation 
aws iam attach-role-policy  --role-name BURoleForSREAutomation --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore  --profile dsprod 
aws iam attach-role-policy  --role-name BURoleForSREAutomation --policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy  --profile dsprod 
aws iam attach-role-policy  --role-name BURoleForSREAutomation --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM  --profile dsprod


aws kafka describe-cluster `
  --cluster-arn arn:aws:kafka:sa-east-1:662860092544:cluster/ds-msk-prod/90e49179-2238-4ac2-8de1-29e44d56c731-3 `
  --profile dsprod `
  --query "ClusterInfo.ZookeeperConnectString"

aws kafka list-nodes `
  --cluster-arn arn:aws:kafka:sa-east-1:662860092544:cluster/ds-msk-prod/90e49179-2238-4ac2-8de1-29e44d56c731-3 `
  --profile dsprod `
  --query "NodeInfoList[].BrokerNodeInfo.BrokerId" `
  --output text