.\saml2aws.exe login -a eec-aws-br-eits-devexperience-sandbox
aws s3api put-bucket-tagging --bucket aws-quicksetup-patchpolicy-246255858577-5bwwk --tagging file://tagging.json --profile devexperience-sandbox
aws s3api put-bucket-tagging --bucket aws-quicksetup-patchpolicy-access-log-246255858577-bfb2-5bwwk --tagging file://tagging.json --profile devexperience-sandbox
aws s3api put-bucket-tagging --bucket cockpit-devsecops-states-246255858577 --tagging file://tagging.json --profile devexperience-sandbox
aws s3api put-bucket-tagging --bucket devexperience-sandbox-tfstate --tagging file://tagging.json --profile devexperience-sandbox

aws s3api get-bucket-tagging --bucket aws-quicksetup-patchpolicy-246255858577-5bwwk  --profile devexperience-sandbox
aws s3api get-bucket-tagging --bucket aws-quicksetup-patchpolicy-access-log-246255858577-bfb2-5bwwk  --profile devexperience-sandbox
aws s3api get-bucket-tagging --bucket cockpit-devsecops-states-246255858577  --profile devexperience-sandbox
aws s3api get-bucket-tagging --bucket devexperience-sandbox-tfstate  --profile devexperience-sandbox

.\saml2aws.exe login -a eec-aws-br-eits-devexperience-dev
aws s3api put-bucket-tagging --bucket cockpit-devsecops-states-015334905722 --tagging file://tagging.json --profile devexperience-dev
aws s3api put-bucket-tagging --bucket devex-devhubportal-dev --tagging file://tagging.json --profile devexperience-dev
aws s3api put-bucket-tagging --bucket devexperience-dev-tfstate --tagging file://tagging.json --profile devexperience-dev

aws s3api get-bucket-tagging --bucket cockpit-devsecops-states-015334905722 --profile devexperience-dev
aws s3api get-bucket-tagging --bucket devex-devhubportal-dev --profile devexperience-dev
aws s3api get-bucket-tagging --bucket devexperience-dev-tfstate --profile devexperience-dev

.\saml2aws.exe login -a eec-aws-br-eits-devexperience-prod
aws s3api put-bucket-tagging --bucket cockpit-devsecops-states-562223391796 --tagging file://tagging.json --profile devexperience-prod
aws s3api put-bucket-tagging --bucket devexperience-prod-tfstate --tagging file://tagging.json --profile devexperience-prod

aws s3api get-bucket-tagging --bucket cockpit-devsecops-states-562223391796 --profile devexperience-prod
aws s3api get-bucket-tagging --bucket devexperience-prod-tfstate --profile devexperience-prod

.\saml2aws.exe login -a eec-aws-br-eits-devexperience-uat
aws s3api put-bucket-tagging --bucket devexperience-uat-tfstate --tagging file://tagging.json --profile devexperience-uat	

aws s3api get-bucket-tagging --bucket devexperience-uat-tfstate --profile devexperience-uat

.\saml2aws.exe login -a eec-aws-br-eits-devhub-sandbox
aws s3api put-bucket-tagging --bucket cockpit-devsecops-states-071087690196 --tagging file://tagging.json --profile devhub-sandbox

aws s3api get-bucket-tagging --bucket cockpit-devsecops-states-071087690196 --profile devhub-sandbox

.\saml2aws.exe login -a eec-aws-br-eits-dx-lab02-sandbox
aws s3api put-bucket-tagging --bucket tfstate-lab02 --tagging file://tagging.json --profile lab02

aws s3api get-bucket-tagging --bucket tfstate-lab02 --profile lab02

.\saml2aws.exe login -a eec-aws-br-eits-dx-lab04-sandbox
aws s3api put-bucket-tagging --bucket airflow-bucket-v1 --tagging file://tagging.json --profile lab04

aws s3api get-bucket-tagging --bucket airflow-bucket-v1 --profile lab04

aws s3api put-bucket-tagging --bucket aws-quicksetup-patchpolicy-246255858577-5bwwk --tagging file://tagging.json --profile devexperience-sandbox
aws s3api put-bucket-tagging --bucket aws-quicksetup-patchpolicy-access-log-246255858577-bfb2-5bwwk --tagging file://tagging.json --profile devexperience-sandbox
aws s3api put-bucket-tagging --bucket cockpit-devsecops-states-246255858577 --tagging file://tagging.json --profile devexperience-sandbox

aws s3api get-bucket-tagging --bucket aws-quicksetup-patchpolicy-246255858577-5bwwk --profile devexperience-sandbox
aws s3api get-bucket-tagging --bucket aws-quicksetup-patchpolicy-access-log-246255858577-bfb2-5bwwk --profile devexperience-sandbox
aws s3api get-bucket-tagging --bucket cockpit-devsecops-states-246255858577 --profile devexperience-sandbox

.\saml2aws.exe login -a eec-aws-br-eits-devhub-dev
aws s3api put-bucket-tagging --bucket cockpit-devsecops-states-977554819825 --tagging file://tagging.json --profile devhub-dev

aws s3api get-bucket-tagging --bucket cockpit-devsecops-states-977554819825 --profile devhub-dev



aws s3api put-bucket-tagging --bucket cockpit-devsecops-states-071087690196 --tagging file://tagging.json --profile devhub-sandbox

aws s3api get-bucket-tagging --bucket cockpit-devsecops-states-071087690196 --profile devhub-sandbox





