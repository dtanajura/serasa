#!/usr/bin/env bash
set -euo pipefail

PROFILE="datahubprod"
REGION="sa-east-1"

BUCKETS=(
  aws-cloudtrail-logs-415071355886-ea2d359b
  cf-templates-g82zui5vtuko-sa-east-1
  experian-consentimento-firehose-prod
  experian-datahub-comporta-serverlessdeploymentbuck-ithyyaxotbdi
  experian-datahub-renda-se-serverlessdeploymentbuck-mc0oyayjwbqg
  experian-datahub-renda-se-serverlessdeploymentbuck-sqyfuxnfosqg
  experian-datahub-renda-va-serverlessdeploymentbuck-ujd2jwycvomr
  tfstate-415071355886-sa-east-1-prd
)

for B in "${BUCKETS[@]}"; do
  echo ">> Processando bucket: $B"

  # 1) Ler tags existentes (se não existir TagSet, retorna array vazio)
  EXISTING=$(aws s3api get-bucket-tagging \
    --profile "$PROFILE" \
    --region "$REGION" \
    --bucket "$B" \
    --query "TagSet" 2>/dev/null || echo "[]")

  # 2) Remove as tags que vamos atualizar (AppID, Environment, CostString)
  CLEANED=$(jq 'map(select(.Key != "AppID" and .Key != "Environment" and .Key != "CostString"))' <<< "$EXISTING")

  # 3) Adiciona as tags atualizadas
  UPDATED=$(jq '. += [
      {"Key":"AppID", "Value":"23008"},
      {"Key":"Environment", "Value":"prd"},
      {"Key":"CostString", "Value":"1800.BR.134.602018"}
    ]' <<< "$CLEANED")

  # (NOVO) Exibir o TagSet que será aplicado
  echo ">> TagSet FINAL a ser aplicado (UPDATED) no bucket: $B"
  jq '.' <<< "$UPDATED"
  echo

  # 4) Aplica as tags de volta sem perder nada
  aws s3api put-bucket-tagging \
    --profile "$PROFILE" \
    --region "$REGION" \
    --bucket "$B" \
    --tagging "$(jq -c '{TagSet: .}' <<< "$UPDATED")"

  echo ">> Tags atualizadas com sucesso em $B"
  echo

  # (NOVO) Buscar e exibir as tags que ficaram no bucket após aplicar
  echo ">> TagSet ATUAL no bucket (pós-aplicação): $B"
  aws s3api get-bucket-tagging \
    --profile "$PROFILE" \
    --region "$REGION" \
    --bucket "$B" \
    --query "TagSet" \
    --output json | jq '.'

  echo
done
