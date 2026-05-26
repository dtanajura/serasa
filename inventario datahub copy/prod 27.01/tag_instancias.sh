#!/usr/bin/env bash
set -euo pipefail

PROFILE="datahubprod"
REGION="sa-east-1"

INSTANCES=(
i-001d041ed30825c48
i-02caa5bbfc2a5c2ca
i-02dbb74881fa0cb01
i-0611512460df0e03c
i-06c67a274073779c2
i-0735596aa98339798
i-083774a9cc2c3f71d
i-0a2b909f56f45be63
i-0c7c6cd2abc3bc583
i-0d2b57e3fd5c4e3dd
i-0df8a643966a17d45
)

echo "Aplicando tags nas instâncias..."

aws ec2 create-tags \
  --profile "$PROFILE" \
  --region "$REGION" \
  --resources "${INSTANCES[@]}" \
  --tags Key=Environment,Value=prd

echo "Concluído! Tags aplicadas com sucesso."