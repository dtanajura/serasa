Set-Location "C:\Users\c96531a\OneDrive - EXPERIAN SERVICES CORP\serasa\firehose"
saml2aws.exe login -a eec-aws-br-eits-datahub-prod
$profile_aws = "datahubprod"

aws s3 mb s3://experian-consentimento-firehose-prod --profile $profile_aws

aws iam create-role --role-name BURoleForGlueCrawler --assume-role-policy-document file://trust.json --profile $profile_aws
aws iam attach-role-policy  --role-name BURoleForGlueCrawler  --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess --profile $profile_aws
aws iam attach-role-policy  --role-name BURoleForGlueCrawler  --policy-arn arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole --profile $profile_aws
