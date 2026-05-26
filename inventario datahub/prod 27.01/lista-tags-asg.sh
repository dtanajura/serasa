#!/usr/bin/env bash
set -euo pipefail

PROFILE="${PROFILE:-datahubprod}"
REGION="${REGION:-sa-east-1}"
# Comma-separated list of keys to filter. Example: "AppID,CostString,Environment".
FILTER_KEYS="${FILTER_KEYS:-AppID,CostString,Environment}"
# Output format: table|json|text
OUTPUT_FORMAT="${OUTPUT_FORMAT:-table}"

ASG_ARNS=(
arn:aws:autoscaling:sa-east-1:415071355886:autoScalingGroup:5f2b3dff-025e-40dc-8f4e-fbff1a4b8a4f:autoScalingGroupName/eks-EKS-datahub-prod-NG-infra-08012026-04cdd034-55d8-a952-56d5-105008efeb61
arn:aws:autoscaling:sa-east-1:415071355886:autoScalingGroup:6041c02f-30fc-416e-b30c-a584a6f3ea31:autoScalingGroupName/eks-EKS-datahub-prod-NG-small-20240321140228055400000044-dac730a9-00cf-23ab-1437-74d1f23b1d6a
arn:aws:autoscaling:sa-east-1:415071355886:autoScalingGroup:879978d4-81f0-4ef1-898f-fa2d4085522b:autoScalingGroupName/eks-EKS-datahub-prod-NG-spot-20240321140228054500000042-6ac730a9-00ca-fb44-59f0-83b36d31834e
arn:aws:autoscaling:sa-east-1:415071355886:autoScalingGroup:ab1cb34e-52dd-4e99-98a6-2e513b3708b8:autoScalingGroupName/eks-EKS-datahub-prod-NG-medium-20240321140228052800000040-36c730a9-00cb-a459-4959-8a4348cb0cd5
arn:aws:autoscaling:sa-east-1:415071355886:autoScalingGroup:c472f432-acfd-4391-9d92-cfa59a5dcb43:autoScalingGroupName/eks-EKS-datahub-prod-NG-infra-20240321135853984300000019-6ec730a7-5eb1-1403-d497-f43e0f9c121f
arn:aws:autoscaling:sa-east-1:415071355886:autoScalingGroup:dc0e67ac-3a1e-4808-9f7b-46807da6051b:autoScalingGroupName/eks-EKS-datahub-prod-NG-spot-08012026-7acdd02d-7b0d-da24-9b00-cb4594415b88
arn:aws:autoscaling:sa-east-1:415071355886:autoScalingGroup:e4d4dff2-f7d0-4efd-bcce-e243035b4a2e:autoScalingGroupName/eks-EKS-datahub-prod-NG-large-08012026-facdd033-efe8-8239-1f91-2bdced828545
arn:aws:autoscaling:sa-east-1:415071355886:autoScalingGroup:e81fb3bd-be86-4ed4-ac0d-7bb0f812735b:autoScalingGroupName/eks-EKS-datahub-prod-NG-large-20240321140228057000000046-9cc730a9-00d1-6821-119b-000b070cc77e
arn:aws:autoscaling:sa-east-1:415071355886:autoScalingGroup:f1140eb4-fb07-43e3-9fdb-68cc2d4aeaa0:autoScalingGroupName/eks-EKS-datahub-prod-NG-small-08012026-a6cdd02f-0a75-84e0-8cd2-8dca12cb107a
arn:aws:autoscaling:sa-east-1:415071355886:autoScalingGroup:fceea2a6-316d-4181-b8a7-7b2a53c5c555:autoScalingGroupName/eks-EKS-datahub-prod-NG-medium-08012026-64cdd033-793e-278f-ac1c-78fbf85130df
)

# Extrai nomes das ASGs a partir dos ARNs (tudo após 'autoScalingGroupName/')
ASG_NAMES=()
for ARN in "${ASG_ARNS[@]}"; do
  ASG_NAMES+=( "${ARN##*/}" )
done

# Monta filtros do describe-tags
FILTERS=( )
# Filtra por nomes de ASG
FILTERS+=( "Name=auto-scaling-group,Values=$(IFS=, ; echo "${ASG_NAMES[*]}")" )

# Se FILTER_KEYS não for vazio, adiciona filtro por chaves
if [[ -n "${FILTER_KEYS}" ]]; then
  FILTERS+=( "Name=key,Values=$(echo "${FILTER_KEYS}" | tr -d ' ')" )
fi

# Query e output
case "${OUTPUT_FORMAT}" in
  table)
    QUERY='Tags[].{ASG:ResourceId,Key:Key,Value:Value,PropagateAtLaunch:PropagateAtLaunch}'
    OUTFMT="table"
    ;;
  json)
    QUERY='Tags[].{ASG:ResourceId,Key:Key,Value:Value,PropagateAtLaunch:PropagateAtLaunch}'
    OUTFMT="json"
    ;;
  text)
    QUERY='Tags[].join(`=`,[ResourceId,Key,Value])'
    OUTFMT="text"
    ;;
  *)
    echo "OUTPUT_FORMAT inválido: ${OUTPUT_FORMAT}. Use table|json|text." >&2
    exit 1
    ;;
esac

aws autoscaling describe-tags \
  --profile "${PROFILE}" \
  --region "${REGION}" \
  --filters "${FILTERS[@]}" \
  --query "${QUERY}" \
  --output "${OUTFMT}"