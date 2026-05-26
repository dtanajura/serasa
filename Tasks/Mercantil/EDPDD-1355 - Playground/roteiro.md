# Verificar a Role da aplicação em prod
# Fazer login na conta
okta-aws-cli web --profile datahubprod --aws-region sa-east-1 --aws-session-duration 36000     

# Ver qual o cluster da conta
aws eks list-clusters --profile datahubprod
{
    "clusters": [
        "datahub-prod"
    ]
}

# Obter contexto do kubeconfig
aws eks update-kubeconfig --name datahub-prod --profile datahubprod

# Verificar qual namespace a aplicação está
kubectl get ns
NAME                                  STATUS   AGE
...
eits-datahub-plataforma-prod          Active   515d
...

kubectl get pod -n eits-datahub-plataforma-prod
NAME                                                READY   STATUS    RESTARTS   AGE
experian-datahub-plataforma-api-7c67464956-v9sb5    1/1     Running   0          32d
experian-datahub-plataforma-front-9f58f68fb-6t2b7   1/1     Running   0          32d

kubectl describe pod experian-datahub-plataforma-api-7c67464956-v9sb5 -n eits-datahub-plataforma-prod
...
Controlled By:  ReplicaSet/experian-datahub-plataforma-api-7c67464956
...
    Environment:
...
      AWS_ROLE_ARN:                 arn:aws:iam::415071355886:role/BURoleForDatahubEKS
      AWS_WEB_IDENTITY_TOKEN_FILE:  /var/run/secrets/eks.amazonaws.com/serviceaccount/token
...

# verificar as permissões atuais da role
aws iam get-role \
  --role-name BURoleForDatahubEKS \
  --profile datahubprod \
  --output json
{
    "Role": {
        "Path": "/",
        "RoleName": "BURoleForDatahubEKS",
        "RoleId": "AROAWBJBOIPXLGIYHJFZS",
        "Arn": "arn:aws:iam::415071355886:role/BURoleForDatahubEKS",
        "CreateDate": "2024-12-03T20:29:52+00:00",
        "AssumeRolePolicyDocument": {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {
                        "Federated": "arn:aws:iam::415071355886:oidc-provider/oidc.eks.sa-east-1.amazonaws.com/id/8D377BE70D6D0FFC6C98F06AB185BA9D"
                    },
                    "Action": "sts:AssumeRoleWithWebIdentity",
                    "Condition": {
                        "StringLike": {
                            "oidc.eks.sa-east-1.amazonaws.com/id/8D377BE70D6D0FFC6C98F06AB185BA9D:sub": "system:serviceaccount:eits-datahub-plataforma-prod:saeks"
                        }
                    }
                }
            ]
        },
        "MaxSessionDuration": 3600,
        "RoleLastUsed": {
            "LastUsedDate": "2026-02-10T12:55:49+00:00",
            "Region": "sa-east-1"
        }
    }
}

# Verificar policies atachadas e inline
echo "Attached policies:" && \
aws iam list-attached-role-policies \
  --role-name BURoleForDatahubEKS \
  --profile datahubprod --output table

echo "Inline policies:" && \
aws iam list-role-policies \
  --role-name BURoleForDatahubEKS \
  --profile datahubprod --output table

Attached policies:
---------------------------------------------------------------------------------------
|                              ListAttachedRolePolicies                               |
+-------------------------------------------------------------------------------------+
||                                 AttachedPolicies                                  ||
|+---------------------------------------------------------+-------------------------+|
||                        PolicyArn                        |       PolicyName        ||
|+---------------------------------------------------------+-------------------------+|
||  arn:aws:iam::415071355886:policy/BUPolicyForDatahubEKS |  BUPolicyForDatahubEKS  ||
||  arn:aws:iam::415071355886:policy/BUPolicyForAssumeRole |  BUPolicyForAssumeRole  ||
|+---------------------------------------------------------+-------------------------+|
Inline policies:
------------------
|ListRolePolicies|
+----------------+

# Criar uma nova policy inline na Role da aplicação em prod (fazer CHG2815312)
aws iam put-role-policy \
  --role-name BURoleForDatahubEKS \
  --policy-name AllowInvokeLambdaDEV-Studio \
  --policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "InvokeLambdaDEV",
        "Effect": "Allow",
        "Action": [
          "lambda:InvokeFunction",
          "lambda:InvokeAsync"
        ],
        "Resource": "arn:aws:lambda:sa-east-1:730335661246:function:experian-datahub-studio-dev"
      }
    ]
  }' \
  --profile datahubprod

  # na conta de DEV criar uma permissão de acesso para a Lambda
  aws lambda add-permission \
  --function-name arn:aws:lambda:sa-east-1:730335661246:function:experian-datahub-studio-dev \
  --statement-id allow-prod-eks-plataforma-api \
  --action lambda:InvokeFunction \
  --principal arn:aws:iam::415071355886:role/BURoleForDatahubEKS \
  --region sa-east-1 \
  --profile datahubdev
