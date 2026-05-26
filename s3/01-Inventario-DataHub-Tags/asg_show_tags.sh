#!/usr/bin/env bash
set -euo pipefail

PROFILE="datahubstage"
REGION="sa-east-1"

ASG_ARNS=(
  arn:aws:autoscaling:sa-east-1:527623259369:autoScalingGroup:0bd4a02f-3d3e-4e84-a2cc-5fb63dcbcf1d:autoScalingGroupName/eks-EKS-datahub-uat-uat-NG-large-20251112195413977900000014-d2cd3cd1-054b-161c-7cbd-31ae3d087dc9
  arn:aws:autoscaling:sa-east-1:527623259369:autoScalingGroup:49b7a6c2-68cb-4079-9086-885aa7f143e0:autoScalingGroupName/eks-EKS-datahub-uat-uat-NG-infra-20251112195146088900000004-cacd3ccf-e482-a434-5cf9-d0f3a60b753e
  arn:aws:autoscaling:sa-east-1:527623259369:autoScalingGroup:50e8af6f-8386-434e-8a50-375fda34e0ed:autoScalingGroupName/eks-EKS-datahub-uat-uat-NG-spot-20251112195413976100000012-66cd3cd1-054b-b35c-3e7d-741c5ede8126
  arn:aws:autoscaling:sa-east-1:527623259369:autoScalingGroup:e1166636-3570-4bee-857d-00aaca3d8910:autoScalingGroupName/eks-EKS-datahub-uat-uat-NG-small-20251112195413973400000010-0ecd3cd1-0546-4d8a-8443-3f7eaf128aa5
  arn:aws:autoscaling:sa-east-1:527623259369:autoScalingGroup:f9a694d6-24e3-4eff-808f-40d701b97c28:autoScalingGroupName/eks-EKS-datahub-uat-uat-NG-medium-2025111219541396210000000e-b4cd3cd1-0543-0d4b-8a4c-d00a173e9cc1
)

# Extrai nomes a partir dos ARNs (mesma lógica do seu script)
ASG_NAMES=()
for ARN in "${ASG_ARNS[@]}"; do
  ASG_NAMES+=( "${ARN##*/}" )
done

echo ">> Profile: ${PROFILE} | Region: ${REGION}"
echo ">> ASGs: ${#ASG_NAMES[@]}"
echo

# Lista TODAS as tags (Key/Value/PropagateAtLaunch) desses ASGs
# Saída em texto “tabulado”
aws autoscaling describe-tags \
  --profile "$PROFILE" \
  --region "$REGION" \
  --filters "Name=auto-scaling-group,Values=$(IFS=,; echo "${ASG_NAMES[*]}")" \
  --query "Tags[].[ResourceId,Key,Value,PropagateAtLaunch]" \
  --output table