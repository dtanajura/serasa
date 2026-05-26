# ligar e desligar eks

## 📌 Descrição

Pasta: `ligar e desligar eks`

**Scripts Python encontrados:**
- `eks.py`

## 🐍 Scripts Python

### eks.py

**Descrição:** # apiVersion: v1
# clusters:
# - cluster:
#     server: {cluster_endpoint}
#     certificate-authority-data: {cluster_cert}
#   name: {cluster_name}
# contexts:
# - context:
#     cluster: {cluster_name}
#     user: aws
#   name: {cluster_name}
# current-context: {cluster_name}
# kind: Config
# preferences: {{}}
# users:
# - name: aws
#   user:
#     exec:
#       apiVersion: client.authentication.k8s.io/v1alpha1
#       command: aws
#       args:
#         - "eks"
#         - "get-token"
#         - "--cluster-name"
#         - "{cluster_name}"
#         - "--region"
#         - "{region}"
#

**Bibliotecas usadas:** `boto3`, `botocore`, `kubernetes`, `json`, `sys`, `tempfile`, `subprocess`

**Entrada esperada:** Parâmetros não especificados

**Como usar:**
```bash
python eks.py [argumentos]
```


## 📋 Pré-requisitos

- Python 3.6+
- Bibliotecas necessárias:
  - `boto3`
  - `botocore`
  - `kubernetes`
  - `subprocess`
  - `tempfile`

**Instalar dependências:**
```bash
pip install -r requirements.txt
```

## ⚠️ Observações Importantes

- Sempre testar em ambiente DEV antes de executar em PROD
- Revisar o roteiro antes de executar automaticamente
- Fazer backup dos dados antes de operações destrutivas
- Verificar credenciais e permissões necessárias

## 📞 Suporte

Para dúvidas ou problemas:
1. Verifique o arquivo `roteiro.sh` ou `roteiro.txt`
2. Consulte os comentários nos scripts Python
3. Revise os arquivos de configuração

---

*Documentação gerada automaticamente - Última atualização: 2026-05-26*
