# Instale dependências (se precisar)
pip install boto3 botocore

# Executar (confirmação interativa)
python s3_bucket_nuke.py --bucket NOME-DO-BUCKET --profile MEU_PROFILE

# Sem confirmação
python s3_bucket_nuke.py --bucket NOME-DO-BUCKET --profile MEU_PROFILE --yes

# Com MFA Delete (se exigido)
python s3_bucket_nuke.py --bucket NOME-DO-BUCKET --profile MEU_PROFILE \
  --mfa-serial arn:aws:iam::123456789012:mfa/seu_usuario --mfa-code 123456 --yes

# Com bypass de governance retention (Object Lock)
python s3_bucket_nuke.py --bucket NOME-DO-BUCKET --profile MEU_PROFILE \
  --bypass-governance --yes

# Abortar multipart uploads pendentes antes de apagar
python s3_bucket_nuke.py --bucket NOME-DO-BUCKET --profile MEU_PROFILE \
  --abort-mpu --yes