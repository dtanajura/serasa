# Listar Roles dos Node Groups

## 📌 Objetivo

Extrair e listar todos os **EKS Node Groups** em **múltiplas contas AWS** juntamente com suas **roles IAM** associadas.

## 🎯 O que este projeto faz

Este projeto automatiza a descoberta de Node Groups (grupos de nós) em clusters EKS espalhados por várias contas AWS e lista as IAM Roles que cada um deles utiliza.

**Use Case:** Auditoria de segurança, inventário de infraestrutura Kubernetes, validação de permissões.

---

## 🚀 Roteiro de Execução Detalhado

O arquivo `roteiro.sh` executa as seguintes operações:

### 1. **Autenticação em Múltiplas Contas AWS**
O script faz login em 14 contas diferentes usando `saml2aws`:
- `eec-aws-br-nike-corporate-prod` (Conta corporativa produção)
- `eec-aws-br-nike-architecture-sandbox` (Sandbox arquitetura)
- `eec-aws-br-nike-ssrm-dev` (SSRM desenvolvimento)
- ... (e mais 11 contas)

**Comando:** `saml2aws.exe login -a <account-name>`

### 2. **Preparação de Perfis AWS**
Define um array com 14 perfis AWS CLI pré-configurados:
```
corporateprod
arcsandbox
ssrmdev
ssrmsandbox
ssrmprod
corporatedev
sredev
dsstage
dsprod
dsdev
datahubdev
datahubprod
consentdev
consentprod
```

### 3. **Execução do Script Python para Cada Perfil**
Para cada perfil, executa:
```bash
python lista.py <perfil>
```

Isto permite coletar dados de TODAS as contas simultaneamente.

---

## 🐍 Script Python: `lista.py`

### Descrição Funcional

Este script **lista todos os EKS Node Groups e suas IAM Roles** em uma conta AWS específica.

### Como Funciona

```python
# 1. Recebe o perfil AWS como argumento
python lista.py corporateprod

# 2. Conecta à conta AWS usando o perfil
session = boto3.Session(profile_name='corporateprod')

# 3. Obtém o ID da conta
account_id = sts_client.get_caller_identity()['Account']
# Resultado: 123456789012

# 4. Lista TODOS os clusters EKS na conta
clusters = client.list_clusters()['clusters']
# Resultado: ['cluster-prod-1', 'cluster-prod-2', ...]

# 5. Para CADA cluster, lista seus Node Groups
for cluster in clusters:
    nodegroups = client.list_nodegroups(clusterName=cluster)['nodegroups']
    # Resultado: ['nodegroup-1', 'nodegroup-2', ...]

# 6. Para CADA Node Group, obtém os detalhes incluindo a Role
for nodegroup in nodegroups:
    ng_details = client.describe_nodegroup(...)
    iam_role = ng_details['nodegroup']['nodeRole']
    # Resultado: arn:aws:iam::123456789012:role/eks-nodegroup-role
```

### Entrada (Argumentos)

```bash
python lista.py <aws-profile-name>
```

**Exemplo:**
```bash
python lista.py corporateprod
python lista.py datahubdev
python lista.py ssrmdev
```

### Saída (O que ele retorna)

Imprime no console:
```
Conta: corporateprod - 123456789012
Cluster: prod-eks-cluster-1
  Nodegroup: nodegroup-prod-1
    IAM Role: arn:aws:iam::123456789012:role/NodeInstanceRole-prod-1
  Nodegroup: nodegroup-prod-2
    IAM Role: arn:aws:iam::123456789012:role/NodeInstanceRole-prod-2
Cluster: prod-eks-cluster-2
  Nodegroup: nodegroup-prod-3
    IAM Role: arn:aws:iam::123456789012:role/NodeInstanceRole-prod-3
```

### Bibliotecas Usadas

- **`boto3`**: SDK AWS para Python
  - `sts_client`: Para obter ID da conta
  - `eks_client`: Para listar clusters e node groups

- **`sys`**: Para receber argumentos da linha de comando

### Validações

O script valida:
```python
if len(sys.argv) != 2:
    print("Usage: python script.py <aws-profile-name>")
    sys.exit(1)
```

Se você não passar o perfil, o script mostra um erro com instruções de uso.

---

## 🔄 Fluxo Completo de Execução

```
Início
  ↓
1. Autenticar em todas as 14 contas (saml2aws login)
  ↓
2. Para cada perfil AWS (corporateprod, arcsandbox, ...):
    ├─ Executar: python lista.py <perfil>
    │  ├─ Conectar à conta AWS
    │  ├─ Listar clusters EKS
    │  ├─ Para cada cluster, listar node groups
    │  ├─ Para cada node group, obter role IAM
    │  └─ Imprimir resultados
    │
  ↓
Fim - Relatório completo de 14 contas
```

---

## 📋 Pré-requisitos

### Software Necessário

1. **Python 3.6+**
   ```bash
   python --version
   ```

2. **Bibliotecas Python**
   ```bash
   pip install boto3
   ```

3. **saml2aws** - Ferramenta de autenticação
   ```bash
   # Windows
   choco install saml2aws
   
   # macOS
   brew install saml2aws
   
   # Linux
   wget https://github.com/Versent/saml2aws/releases/download/v2.36.3/saml2aws_2.36.3_linux_amd64.tar.gz
   tar xvf saml2aws_2.36.3_linux_amd64.tar.gz
   sudo mv saml2aws /usr/local/bin/
   ```

4. **AWS CLI v2**
   ```bash
   # Instalar de https://aws.amazon.com/cli/
   aws --version
   ```

### Configuração AWS

1. **Configurar Perfis saml2aws**
   ```bash
   saml2aws configure -a corporateprod
   saml2aws configure -a arcsandbox
   # ... para cada conta
   ```

2. **Fazer Login (antes de executar)**
   ```bash
   saml2aws login -a corporateprod
   saml2aws login -a arcsandbox
   # ... para cada conta
   ```
   
   Ou deixar o roteiro fazer automaticamente

3. **Permissões Necessárias**
   - `eks:ListClusters` (listar clusters)
   - `eks:ListNodegroups` (listar node groups)
   - `eks:DescribeNodegroup` (obter detalhes do node group)
   - `sts:GetCallerIdentity` (obter ID da conta)

---

## 💡 Exemplos Práticos

### Exemplo 1: Executar para uma única conta

```bash
cd /path/to/Listar\ Roles\ dos\ Node\ Groups
python lista.py corporateprod
```

**Saída:**
```
Conta: corporateprod - 123456789012
Cluster: prod-eks-cluster-1
  Nodegroup: nodegroup-prod-1
    IAM Role: arn:aws:iam::123456789012:role/NodeInstanceRole-prod-1
```

### Exemplo 2: Executar para múltiplas contas manualmente

```bash
python lista.py corporateprod
python lista.py arcsandbox
python lista.py datahubdev
```

### Exemplo 3: Executar tudo automaticamente

```bash
# No Windows PowerShell:
bash roteiro.sh

# Ou no Linux/macOS:
bash roteiro.sh
```

---

## 🐛 Troubleshooting

| Erro | Causa | Solução |
|------|-------|---------|
| `ModuleNotFoundError: No module named 'boto3'` | Biblioteca não instalada | `pip install boto3` |
| `NoCredentialsError` | Sem credenciais AWS | `saml2aws login -a <account>` |
| `An error occurred (AccessDenied)` | Sem permissões IAM | Verificar permissões na conta AWS |
| `usage: python script.py <aws-profile-name>` | Argumento não fornecido | `python lista.py corporateprod` |
| `UnrecognizedClientException` | SAML2AWS expirado | Fazer login novamente: `saml2aws login -a <account>` |

---

## ⚠️ Observações Importantes

- ✅ Este script é **SOMENTE LEITURA** - não modifica nada
- ✅ Seguro para executar em PROD
- ⏱️ Pode levar alguns minutos se houver muitos clusters
- 📝 Os resultados são impressos no console (considere redirecionar para arquivo: `bash roteiro.sh > output.txt`)
- 🔑 Credenciais SAML2AWS expiram, pode ser necessário fazer login novamente

---

## 📊 Casos de Uso

1. **Auditoria de Segurança**: Verificar se roles estão com permissões corretas
2. **Inventário**: Mapear todos os EKS clusters e node groups
3. **Documentação**: Gerar relatório de infraestrutura
4. **Validação**: Confirmar que roles estão nomeadas corretamente
5. **Troubleshooting**: Identificar problemas de permissões

---

## 📞 Suporte

Se tiver dúvidas:
1. Revise o arquivo `roteiro.sh` original
2. Consulte comentários no `lista.py`
3. Verifique se `saml2aws` está corretamente configurado
4. Confirme que tem as permissões IAM necessárias

---

*Documentação detalhada - Última atualização: 2026-05-26*
