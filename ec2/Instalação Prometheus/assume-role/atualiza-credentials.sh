#!/bin/bash

# Variáveis
ROLE_ARN="arn:aws:iam::877001948254:role/BURoleForObservabilidadeDestino"
SESSION_NAME="ssrmprod"
PROFILE_NAME="assumed-role"

# Executa o comando assume-role e captura as credenciais
CREDENTIALS=$(aws sts assume-role --role-arn $ROLE_ARN --role-session-name $SESSION_NAME --output json)

# Extrai AccessKeyId, SecretAccessKey e SessionToken das credenciais
ACCESS_KEY_ID=$(echo $CREDENTIALS | jq -r '.Credentials.AccessKeyId')
SECRET_ACCESS_KEY=$(echo $CREDENTIALS | jq -r '.Credentials.SecretAccessKey')
SESSION_TOKEN=$(echo $CREDENTIALS | jq -r '.Credentials.SessionToken')

# Verifica se as credenciais foram extraídas corretamente
if [ -z "$ACCESS_KEY_ID" ] || [ -z "$SECRET_ACCESS_KEY" ] || [ -z "$SESSION_TOKEN" ]; then
  echo "Erro ao obter as credenciais da função assumida"
  exit 1
fi

# Altera o arquivo .aws/credentials com as novas credenciais
AWS_CREDENTIALS_FILE="$HOME/.aws/credentials"

# Adiciona ou substitui as credenciais no arquivo .aws/credentials
awk -v profile="$PROFILE_NAME" -v aws_access_key_id="$ACCESS_KEY_ID" -v aws_secret_access_key="$SECRET_ACCESS_KEY" -v aws_session_token="$SESSION_TOKEN" '
BEGIN {
  found = 0;
}
/^\[/{ in_profile = 0; }
/^\['"$PROFILE_NAME"'\]$/ { in_profile = 1; found = 1; }
in_profile && /^aws_access_key_id/ { $0 = "aws_access_key_id = " aws_access_key_id; }
in_profile && /^aws_secret_access_key/ { $0 = "aws_secret_access_key = " aws_secret_access_key; }
in_profile && /^aws_session_token/ { $0 = "aws_session_token = " aws_session_token; }
{ print; }
END {
  if (!found) {
    print "[" profile "]";
    print "aws_access_key_id = " aws_access_key_id;
    print "aws_secret_access_key = " aws_secret_access_key;
    print "aws_session_token = " aws_session_token;
  }
}
' $AWS_CREDENTIALS_FILE > $AWS_CREDENTIALS_FILE.tmp

mv -f $AWS_CREDENTIALS_FILE.tmp $AWS_CREDENTIALS_FILE

echo "Credenciais atualizadas com sucesso no arquivo $AWS_CREDENTIALS_FILE para o perfil $PROFILE_NAME."
