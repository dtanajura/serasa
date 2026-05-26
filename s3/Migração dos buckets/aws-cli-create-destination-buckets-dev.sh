# Create Buckets
aws s3api create-bucket --bucket experian-drive-private-qa-1 --region us-east-1 --no-verify-ssl --profile devcontanova
aws s3api create-bucket --bucket experian-drive-private-stg-1 --region us-east-1 --no-verify-ssl --profile devcontanova
aws s3api create-bucket --bucket experian-drive-public-stg-1 --region us-east-1 --no-verify-ssl --profile devcontanova
aws s3api create-bucket --bucket serasaexperian-crypto-private-qa-1 --region us-east-1 --no-verify-ssl --profile devcontanova
aws s3api create-bucket --bucket serasaexperian-drive-private-qa-1 --region us-east-1 --no-verify-ssl --profile devcontanova
aws s3api create-bucket --bucket serasaexperian-drive-private-stg-1  --region us-east-1 --no-verify-ssl --profile devcontanova
aws s3api create-bucket --bucket serasaexperian-drive-public-stg-1  --region us-east-1 --no-verify-ssl --profile devcontanova

# Enable Versioning
aws s3api put-bucket-versioning --bucket experian-drive-private-qa-1 --versioning-configuration Status=Enabled --no-verify-ssl --profile devcontanova
aws s3api put-bucket-versioning --bucket experian-drive-private-stg-1 --versioning-configuration Status=Enabled --no-verify-ssl --profile devcontanova
aws s3api put-bucket-versioning --bucket experian-drive-public-stg-1 --versioning-configuration Status=Enabled --no-verify-ssl --profile devcontanova
aws s3api put-bucket-versioning --bucket serasaexperian-crypto-private-qa-1 --versioning-configuration Status=Enabled --no-verify-ssl --profile devcontanova
aws s3api put-bucket-versioning --bucket serasaexperian-drive-private-qa-1 --versioning-configuration Status=Enabled --no-verify-ssl --profile devcontanova
aws s3api put-bucket-versioning --bucket serasaexperian-drive-private-stg-1 --versioning-configuration Status=Enabled --no-verify-ssl --profile devcontanova
aws s3api put-bucket-versioning --bucket serasaexperian-drive-public-stg-1 --versioning-configuration Status=Enabled --no-verify-ssl --profile devcontanova

# Load bucket policy
aws s3api put-bucket-policy --bucket experian-drive-private-qa-1 --policy file://bucket-policy/experian-drive-private-qa-1.json --no-verify-ssl --profile devcontanova
aws s3api put-bucket-policy --bucket experian-drive-private-stg-1 --policy file://bucket-policy/experian-drive-private-stg-1.json --no-verify-ssl --profile devcontanova
aws s3api put-bucket-policy --bucket experian-drive-public-stg-1 --policy file://bucket-policy/experian-drive-public-stg-1.json --no-verify-ssl --profile devcontanova
aws s3api put-bucket-policy --bucket serasaexperian-crypto-private-qa-1 --policy file://bucket-policy/serasaexperian-crypto-private-qa-1.json --no-verify-ssl --profile devcontanova
aws s3api put-bucket-policy --bucket serasaexperian-drive-private-stg-1 --policy file://bucket-policy/serasaexperian-drive-private-stg-1.json --no-verify-ssl --profile devcontanova
aws s3api put-bucket-policy --bucket serasaexperian-drive-public-stg-1 --policy file://bucket-policy/serasaexperian-drive-public-stg-1.json --no-verify-ssl --profile devcontanova
aws s3api put-bucket-policy --bucket serasaexperian-drive-private-qa-1 --policy file://bucket-policy/serasaexperian-drive-private-qa-1.json --no-verify-ssl --profile devcontanova

# Create KMS Key
aws kms create-key --policy file://kms-policy/key.json  --region us-east-1 --description "Key for S3 bucket replication from legacy Digital account"  --no-verify-ssl --profile devcontanova
aws kms create-alias  --alias-name alias/BUKeyForS3Encryption  --region us-east-1 --target-key-id c91ad248-f22d-4054-b05f-4be638728bce  --no-verify-ssl --profile devcontanova

802049031151
burolefordigitaldevops
arn:aws:kms:us-east-1:802049031151:key/c91ad248-f22d-4054-b05f-4be638728bce
s3://file-share-claranet
BURoleForDigitalS3Replication
