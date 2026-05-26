# Variáveis
PROFILE="datahubstage"
REGION="sa-east-1"
ROLE_NAME="BURoleForPositivoMercantil"

# Nomes das customer managed policies (dev -> queremos mesmas na stage)
CM_POLICIES=(
  "eec-aws-baseline-emr-encryption-policy"
  "eec-aws-baseline-emr-role-policy"
  "eec-aws-baseline-emr-ec2-role-policy"
)

# AWS managed policies (ARNs idênticas em qualquer conta)
AWS_POLICIES=(
  "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
  "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role"
  "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
  "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
  "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
)

echo "==> Resolvendo ARNs das customer managed policies na conta stage..."
STAGE_CM_POLICY_ARNS=()

for PNAME in "${CM_POLICIES[@]}"; do
  ARN=$(aws iam list-policies \
          --profile "$PROFILE" \
          --scope Local \
          --region "$REGION" \
          --query "Policies[?PolicyName=='${PNAME}'].Arn | [0]" \
          --output text)

  if [[ "$ARN" == "None" || -z "$ARN" ]]; then
    echo "ERRO: Policy '${PNAME}' não encontrada na conta stage. Crie-a antes de anexar."
    MISSING=1
  else
    echo "OK  : ${PNAME} -> ${ARN}"
    STAGE_CM_POLICY_ARNS+=("$ARN")
  fi
done

if [[ "$MISSING" == "1" ]]; then
  echo "Abortando anexação porque existem policies locais ausentes na stage."
  exit 1
fi

echo "==> Anexando customer managed policies à role ${ROLE_NAME}..."
for PARN in "${STAGE_CM_POLICY_ARNS[@]}"; do
  aws iam attach-role-policy \
    --profile "$PROFILE" \
    --region "$REGION" \
    --role-name "$ROLE_NAME" \
    --policy-arn "$PARN"
done

echo "==> Anexando AWS managed policies à role ${ROLE_NAME}..."
for PARN in "${AWS_POLICIES[@]}"; do
  aws iam attach-role-policy \
    --profile "$PROFILE" \
    --region "$REGION" \
    --role-name "$ROLE_NAME" \
    --policy-arn "$PARN"
done

echo "==> Conferindo policies anexadas:"
aws iam list-attached-role-policies \
  --profile "$PROFILE" \
  --region "$REGION" \
  --role-name "$ROLE_NAME"
