aws emr-serverless start-job-run --application-id "00fhk34d170s7431" --execution-role-arn "arn:aws:iam::187739130313:role/service-role/BURoleForAmazonEMRStudio_Runtime-MVP-Data-Environment-Test" --job-driver file://job-driver.json --configuration-overrides file://configuration-overrides.json --profile devhub-legada-sandbox

# "AccountB-catalog-id"