# Onboard contas positivo e negativo

## 📌 Visão Geral

**Roteiro:** `roteiro.sh`

## 🚀 Roteiro de Execução

Este script executa automaticamente os seguintes passos:

1. `cd "C:\Users\c96531a\OneDrive - EXPERIAN SERVICES CORP\serasa\Onboard contas pos`
2. `aws cloudformation deploy --stack-name ServiceCatalog --capabilities CAPABILITY_`
3. `aws cloudformation deploy --stack-name ServiceCatalog --capabilities CAPABILITY_`
4. `aws cloudformation deploy --stack-name ServiceCatalog --capabilities CAPABILITY_`
5. `account_id - 109804294614`
6. `domain - .serasa.intranet`
7. `Region - us-east-1`
8. `Env - Dev`
9. `Tribe - Positivo`
10. `VPC ID - vpc-02fafde418156c503`
11. `aws ec2 describe-vpcs --profile positivodev --query  "Vpcs[].VpcId" --output tex`
12. `Subnet A - subnet-0ccc0b54c5bbd89a5`
13. `Subnet B - subnet-046dd5974b375e35e`
14. `Subnet C - subnet-014c7f43ebbaa30e2`
15. `aws ec2 describe-subnets  --profile positivodev --output text --query "Subnets[]`
16. `aws servicecatalog describe-product --name Route53SubDomain --output text --prof`
17. `aws servicecatalog describe-product --name Route53SubDomain --output text --prof`
18. `aws servicecatalog describe-product --name Route53SubDomain --output text --prof`
19. `aws servicecatalog describe-provisioning-parameters --product-name Route53SubDom`
20. `aws servicecatalog provision-product  --product-name Route53SubDomain  --provisi`
21. `aws servicecatalog describe-product --name Route53SubDomain --output text --prof`
22. `aws servicecatalog describe-product --name Route53SubDomain --output text --prof`
23. `aws servicecatalog describe-product --name Route53SubDomain --output text --prof`
24. `aws servicecatalog describe-provisioning-parameters --product-name Route53SubDom`
25. `aws servicecatalog provision-product  --product-name Route53SubDomain  --provisi`

... mais 140 passos ...

**Total: 165 passos**

**Como executar:**
```bash
bash roteiro.sh
```

## 📋 Pré-requisitos

**AWS:**
- AWS CLI v2
- Credenciais configuradas
- Permissões apropriadas

## 💡 Exemplos

**Executar roteiro completo:**
```bash
bash roteiro.sh
```

## 🐛 Troubleshooting

| Erro | Solução |
|------|----------|
| Erro de autenticação | `saml2aws login -a <account>` |
| ModuleNotFoundError | `pip install boto3` |
| Acesso negado | Verificar permissões IAM |

## ⚠️ Importante

- ✅ Testar em DEV antes de PROD
- ✅ Revisar scripts antes de executar
- ✅ Fazer backup de dados sensíveis
- ❌ Nunca commitar credenciais AWS

---
*Última atualização: 2026-05-26*
