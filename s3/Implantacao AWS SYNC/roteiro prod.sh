# Configurar o DataSync entre as contas da Warriors e de MLOps
# Origem:
# Nome do bucket: experian-reports-extraction-files-prod/{CD_PROCESSO}/extraction
# Conta: eec-aws-br-eits-nikedataservice-prod (225989352496)

# Destino:
# Nome do bucket: serasaexperian-coe-data-platform-prod-landing
# Conta:  221992887590

# Roteiro: https://docs.aws.amazon.com/datasync/latest/userguide/tutorial_s3-s3-cross-account-transfer.html

##### Criar DataSync service permissions for your source account
# Policy
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetBucketLocation",
        "s3:ListBucket",
        "s3:ListBucketMultipartUploads"
      ],
      "Resource": "arn:aws:s3:::*",
      "Condition": {
        "StringEquals": {
          "aws:ResourceAccount": [
            "225989352496",
            "221992887590"
          ]
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:AbortMultipartUpload",
        "s3:DeleteObject",
        "s3:GetObject",
        "s3:GetObjectTagging",
        "s3:GetObjectVersion",
        "s3:GetObjectVersionTagging",
        "s3:ListMultipartUploadParts",
        "s3:PutObject",
        "s3:PutObjectTagging"
      ],
      "Resource": "arn:aws:s3:::*/*",
      "Condition": {
        "StringEquals": {
          "aws:ResourceAccount": [
            "225989352496",
            "221992887590"
          ]
        }
      }
    }
  ]
}

# Trust
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "datasync.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}

# Crie a role:
aws iam create-role --role-name BURoleForDataSyncService --assume-role-policy-document file://trust_source_account_datasync.json --profile nikedataprod
# "Arn": "arn:aws:iam::225989352496:role/BURoleForDataSyncService"
# Anexe a política inline à role:
aws iam put-role-policy --role-name BURoleForDataSyncService --policy-name PolicyDataSyncService --policy-document file://policy_source_account_datasync.json --profile nikedataprod

# Verifique a política inline:
aws iam get-role-policy --role-name BURoleForDataSyncService --policy-name PolicyDataSyncService --profile nikedataprod

###### Na conta de destino, atualize a policy do bucket S3
# Policy
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "DataSyncCreateS3LocationAndTaskAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::225989352496:role/BURoleForDataSyncService"
      },
      "Action": [
        "s3:GetBucketLocation",
        "s3:ListBucket",
        "s3:ListBucketMultipartUploads",
        "s3:AbortMultipartUpload",
        "s3:DeleteObject",
        "s3:GetObject",
        "s3:ListMultipartUploadParts",
        "s3:PutObject",
        "s3:GetObjectTagging",
        "s3:PutObjectTagging"
      ],
      "Resource": [
        "arn:aws:s3:::teste-aws-sync",
        "arn:aws:s3:::teste-aws-sync/*"
      ]
    }
  ]
}

# configurar policy
aws s3api put-bucket-policy --bucket teste-aws-sync --policy file://s3_policy_destination_account.json --profile architecture-sandbox

##### Desabilitar o ACL no bucket
# Policy

{
  "Rules": [
    {
      "ObjectOwnership": "BucketOwnerEnforced"
    }
  ]
}

# comando
aws s3api put-bucket-ownership-controls --bucket teste-aws-sync --ownership-controls file://policy_bucket_acl_disable_destination_account.json --profile architecture-sandbox

###### criar os datasync location e a task
python datasync_setup.py --source-profile nikedatauat --destination-profile architecture-sandbox --source-bucket experian-reports-extraction-files-uat --destination-bucket teste-aws-sync --source-role-arn arn:aws:iam::225989352496:role/BURoleForDataSyncService --subdirectory /ESPNEG_BB_PF/extraction/

