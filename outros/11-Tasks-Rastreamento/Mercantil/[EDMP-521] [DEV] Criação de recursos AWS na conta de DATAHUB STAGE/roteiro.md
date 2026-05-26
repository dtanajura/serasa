# Contexto
Ao executar uma automação do PIAAS o usuário recebe o erro:
Error:
CREATE_FAILED: ExperianDashdatahubDashvalidaDashremessaDashmercantilLambdaFunction (AWS::Lambda::Function)
Resource handler returned message: "User: arn:aws:iam::527623259369:user/BUUserForDevSecOpsPiaaS is not authorized to perform: iam:PassRole on resource: arn:aws:iam::527623259369:role/BURoleForPositivoMercantil because no identity-based policy allows the iam:PassRole action (Service: Lambda, Status Code: 403, Request ID: 6c6c7a82-53e7-473b-80d9-65bcb93dd0ce) (SDK Attempt Count: 1)" (RequestToken: 856023d3-027b-0258-50db-c577b618fdf8, HandlerErrorCode: AccessDenied)

# Verificar as permissões
Ver permissões do usuário BUUserForDevSecOpsPiaaS
```bash
aws iam list-attached-user-policies \
  --user-name BUUserForDevSecOpsPiaaS --profile datahubstage
{
    "AttachedPolicies": []
}
```

```bash
aws iam list-user-policies \
  --user-name BUUserForDevSecOpsPiaaS --profile datahubstage
{
    "PolicyNames": []
}
```
```bash
aws iam list-groups-for-user \
  --user-name BUUserForDevSecOpsPiaaS --profile datahubstage
{
    "Groups": [
        {
            "Path": "/",
            "GroupName": "BUGroupForDevSecOpsPiaaS",
            "GroupId": "AGPAXVWGMATUV4S56Q5AC",
            "Arn": "arn:aws:iam::527623259369:group/BUGroupForDevSecOpsPiaaS",
            "CreateDate": "2025-10-09T15:50:03+00:00"
        },
        {
            "Path": "/",
            "GroupName": "eec-aws-service-accounts-group",
            "GroupId": "AGPAXVWGMATUYV4Y7JMVA",
            "Arn": "arn:aws:iam::527623259369:group/eec-aws-service-accounts-group",
            "CreateDate": "2025-09-25T19:27:17+00:00"
        }
    ]
}
```

```bash
aws iam list-attached-group-policies \
  --group-name BUGroupForDevSecOpsPiaaS --profile datahubstage
{
    "AttachedPolicies": [
        {
            "PolicyName": "BUPolicyForDevSecOpsPiaaS",
            "PolicyArn": "arn:aws:iam::527623259369:policy/BUPolicyForDevSecOpsPiaaS"
        }
    ]
}
```

```bash 
aws iam get-policy \
  --policy-arn "arn:aws:iam::527623259369:policy/BUPolicyForDevSecOpsPiaaS" --profile datahubstage

{
    "Policy": {
        "PolicyName": "BUPolicyForDevSecOpsPiaaS",
        "PolicyId": "ANPAXVWGMATUT5VKXUOSY",
        "Arn": "arn:aws:iam::527623259369:policy/BUPolicyForDevSecOpsPiaaS",
        "Path": "/",
        "DefaultVersionId": "v7",
```

```bash
aws iam get-policy-version \
  --policy-arn arn:aws:iam::527623259369:policy/BUPolicyForDevSecOpsPiaaS \
  --version-id v7 --profile datahubstage

Documento listado no policy-v7.json
```
