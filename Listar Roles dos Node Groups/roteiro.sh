saml2aws.exe login -a eec-aws-br-nike-corporate-prod
saml2aws.exe login -a eec-aws-br-nike-architecture-sandbox
saml2aws.exe login -a eec-aws-br-nike-ssrm-dev
saml2aws.exe login -a eec-aws-br-nike-ss-sandbox
saml2aws.exe login -a eec-aws-br-nike-sales-prod
saml2aws.exe login -a eec-aws-br-nike-corporate-dev
saml2aws.exe login -a eec-aws-br-eits-nike-sre-management-dev
saml2aws.exe login -a eec-aws-br-ds-dataservices-stage
saml2aws.exe login -a eec-aws-br-ds-dataservices-prod
saml2aws.exe login -a eec-aws-br-ds-dataservices-dev
saml2aws.exe login -a eec-aws-us-eits-datahub-dev
saml2aws.exe login -a eec-aws-br-eits-datahub-prod 
saml2aws.exe login -a eec-aws-us-eits-consent-dev
saml2aws.exe login -a eec-aws-us-eits-consent-prod

$profiles = @(
  "corporateprod",
  "arcsandbox",
  "ssrmdev",
  "ssrmsandbox",
  "ssrmprod",
  "corporatedev",
  "sredev",
  "dsstage",
  "dsprod",
  "dsdev",
  "datahubdev",
  "datahubprod",
  "consentdev",
  "consentprod"
)
foreach ($profileaws  in $profiles) {
    python .\lista.py $profileaws 
}
