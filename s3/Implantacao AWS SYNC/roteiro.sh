# Configurar o DataSync entre as contas da Warriors e de MLOps
# Origem:
# Nome do bucket: experian-reports-extraction-files-uat/{CD_PROCESSO}/extraction
# Conta: eec-aws-br-eits-nikedataservice-uat (713881783816)

# Destino (teste):
# Nome do bucket: teste-aws-sync
# Conta:  eec-aws-br-eits-architecture-sandbox (380979651404)

# Roteiro: https://docs.aws.amazon.com/datasync/latest/userguide/tutorial_s3-s3-cross-account-transfer.html

##### Criar o destination bucket
aws s3 mb s3://teste-aws-sync --profile architecture-sandbox

# Verificar
aws s3 ls --profile architecture-sandbox

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
            "713881783816",
            "380979651404"
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
            "713881783816",
            "380979651404"
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
aws iam create-role --role-name BURoleForDataSyncService --assume-role-policy-document file://trust_source_account_datasync.json --profile nikedatauat
# "Arn": "arn:aws:iam::713881783816:role/BURoleForDataSyncService"
# Anexe a política inline à role:
aws iam put-role-policy --role-name BURoleForDataSyncService --policy-name PolicyDataSyncService --policy-document file://policy_source_account_datasync.json --profile nikedatauat

# Verifique a política inline:
aws iam get-role-policy --role-name BURoleForDataSyncService --policy-name PolicyDataSyncService --profile nikedatauat

###### Na conta de destino, atualize a policy do bucket S3
# Policy
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "DataSyncCreateS3LocationAndTaskAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::713881783816:role/BURoleForDataSyncService"
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
aws s3api put-bucket-policy --bucket teste-aws-sync-3 --policy file://policy_bucket.json --profile architecture-sandbox

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
python datasync_setup.py --source-profile nikedatauat --destination-profile architecture-sandbox --source-bucket experian-reports-extraction-files-uat --destination-bucket teste-aws-sync --source-role-arn arn:aws:iam::713881783816:role/BURoleForDataSyncService --subdirectory /ESPNEG_BB_PF/extraction/

#---------------------------------------------
# Teste 2: criar um novo bucket na conta de destino
# e incluir um assume-role com a permissão

##### Criar o destination bucket
aws s3 mb s3://teste-aws-sync-2 --profile architecture-sandbox

#### Criar o destination assume role
## Policy
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "DataSyncCreateS3LocationAndTaskAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::713881783816:role/BURoleForDataSyncService"
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
        "arn:aws:s3:::teste-aws-sync-2",
        "arn:aws:s3:::teste-aws-sync-2/*"
      ]
    }
  ]
}

## Trust
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::713881783816:role/BURoleForDataSyncService"
      },
      "Action": "sts:AssumeRole",
      "Condition": {}
    }
  ]
}

# Crie a role:
aws iam create-role --role-name BURoleForDataSyncTrust --assume-role-policy-document file://trust_destination_datasync_trust.json --profile architecture-sandbox
# "Arn": "arn:aws:iam::713881783816:role/BURoleForDataSyncService"
# Anexe a política inline à role:
aws iam put-role-policy --role-name BURoleForDataSyncTrust --policy-name PolicyDataSyncService --policy-document file://policy_destination_datasync_trust.json --profile architecture-sandbox

# Verifique a política inline:
aws iam get-role-policy --role-name BURoleForDataSyncTrust --policy-name PolicyDataSyncService --profile architecture-sandbox


$tasks = aws datasync list-tasks --query 'Tasks[*].TaskArn' --output json --profile nikedatauat | ConvertFrom-Json

foreach ($task in $tasks) {
    Write-Output "Excluindo task: $task"
    aws datasync delete-task --task-arn $task --profile nikedatauat
}

$locations = aws datasync list-locations --query 'Locations[*].LocationArn' --output json --profile nikedatauat | ConvertFrom-Json

foreach ($location in $locations) {
    Write-Output "Excluindo location: $location"
    aws datasync delete-location --location-arn $location --profile nikedatauat
}


aws sts assume-role --role-arn arn:aws:iam::225989352496:role/BURoleForDataSyncService --role-session-name list-s3-session --profile nikedataprod
aws datasync update-task --task-arn arn:aws:datasync:sa-east-1:225989352496:task/task-0fce5067181888b8e --cloud-watch-log-group-arn arn:aws:logs:sa-east-1:225989352496:log-group:DataSyncTaskLogGroup-loc-03c46f0f63c7c6e85-loc-0a00a1ee9300026db:*  --profile nikedataprod

aws datasync update-task --task-arn arn:aws:datasync:sa-east-1:225989352496:task/task-0fce5067181888b8e --cloud-watch-log-group-arn arn:aws:logs:sa-east-1:225989352496:log-group:DataSyncTaskLogGroup-loc-03c46f0f63c7c6e85-loc-0a00a1ee9300026db:* --options file://options.json --profile nikedataprod

aws iam put-role-policy --role-name BURoleForDataSyncService --policy-name PolicyDataSyncServiceLogs --policy-document file://policy_logs.json --profile nikedataprod


aws logs put-resource-policy --policy-name "AllowDataSyncLogging" --policy-document file://policy-document.json --profile nikedataprod