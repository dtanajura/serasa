#!/usr/bin/env bash
set -euo pipefail

# ===== Configurações =====
PROFILE_AWS="datahubstage"
PRODUCT_NAME="CustomADGroup"
PARAMS_FILE="provision-parameters-CustomADGroup.json"
ROLE_NAME="BURoleForDatahubOperation"

# ===== Função utilitária para checagens =====
require_non_empty() {
  local value="$1"
  local name="$2"
  if [[ -z "$value" ]]; then
    echo "Erro: valor para '$name' veio vazio." >&2
    exit 1
  fi
}

echo "Usando profile AWS: ${PROFILE_AWS}"
echo "Produto Service Catalog: ${PRODUCT_NAME}"

# ===== Buscar IDs necessários =====

# ProductViewID (pegar o primeiro que bate com o nome do produto)
PRODUCT_VIEW_ID="$(
  aws servicecatalog search-products \
    --profile "${PROFILE_AWS}" \
    --query "ProductViewSummaries[?Name=='${PRODUCT_NAME}'].[Id]" \
    --output text | head -n 1 || true
)"
require_non_empty "${PRODUCT_VIEW_ID}" "ProductViewID"
echo "ProductViewID: ${PRODUCT_VIEW_ID}"

# ProvisioningArtifactsID (pegar o mais recente, se houver vários)
PROVISIONING_ARTIFACT_ID="$(
  aws servicecatalog describe-product \
    --name "${PRODUCT_NAME}" \
    --profile "${PROFILE_AWS}" \
    --query "max_by(ProvisioningArtifacts[], &CreatedTime).Id" \
    --output text || true
)"
require_non_empty "${PROVISIONING_ARTIFACT_ID}" "ProvisioningArtifactsID"
echo "ProvisioningArtifactsID: ${PROVISIONING_ARTIFACT_ID}"

# LaunchPathsID (pegar o primeiro)
LAUNCH_PATH_ID="$(
  aws servicecatalog describe-product \
    --name "${PRODUCT_NAME}" \
    --profile "${PROFILE_AWS}" \
    --query "LaunchPaths[].Id" \
    --output text | awk 'NF{print; exit}' || true
)"
require_non_empty "${LAUNCH_PATH_ID}" "LaunchPathsID"
echo "LaunchPathsID: ${LAUNCH_PATH_ID}"

# ===== (Opcional) Listar parâmetros obrigatórios =====
echo
echo "Parâmetros de provisionamento (visualização):"

echo "aws servicecatalog describe-provisioning-parameters \
  --product-name \"${PRODUCT_NAME}\" \
  --provisioning-artifact-id \"${PROVISIONING_ARTIFACT_ID}\" \
  --path-id \"${LAUNCH_PATH_ID}\" \
  --profile \"${PROFILE_AWS}\" \
  --output table"

# aws servicecatalog describe-provisioning-parameters \
#   --product-name "${PRODUCT_NAME}" \
#   --provisioning-artifact-id "${PROVISIONING_ARTIFACT_ID}" \
#   --path-id "${LAUNCH_PATH_ID}" \
#   --profile "${PROFILE_AWS}" \
#   --output table || true

# ===== Checar arquivo de parâmetros =====
if [[ ! -f "${PARAMS_FILE}" ]]; then
  echo "Erro: arquivo de parâmetros '${PARAMS_FILE}' não encontrado no diretório atual." >&2
  exit 1
fi

# ===== Provisionar o produto =====
PROVISIONED_PRODUCT_NAME="${PRODUCT_NAME}-${ROLE_NAME}"
echo
echo "Provisionando produto '${PRODUCT_NAME}' como '${PROVISIONED_PRODUCT_NAME}'..."

aws servicecatalog provision-product \
  --product-name "${PRODUCT_NAME}" \
  --provisioning-artifact-id "${PROVISIONING_ARTIFACT_ID}" \
  --provisioned-product-name "${PROVISIONED_PRODUCT_NAME}" \
  --provisioning-parameters "file://${PARAMS_FILE}" \
  --path-id "${LAUNCH_PATH_ID}" \
  --profile "${PROFILE_AWS}" \
  --output json

echo "Provisionamento solicitado com sucesso."



while true; do
  STATUS="$(aws servicecatalog search-provisioned-products \
    --profile "${PROFILE_AWS}" \
    --query "ProvisionedProducts[?Name=='${PROVISIONED_PRODUCT_NAME}'].Status" \
    --output text)"

  echo "Status atual: $STATUS"

  if [[ "$STATUS" == "AVAILABLE" ]]; then
    echo "Provisionamento concluído com sucesso!"
    break
  elif [[ "$STATUS" == "ERROR" ]]; then
    echo "Erro no provisionamento!"
    break
  fi

  sleep 10
done


# PolicyArn": "arn:aws:iam::730335661246:policy/BUPolicyForPositivoMercantil"
# "arn:aws:iam::730335661246:policy/BUPolicyForDatahubOperation"
