# vulnerabilidades

## 📌 Descrição

Pasta: `vulnerabilidades`

**Scripts Python encontrados:**
- `atualizacao copy.py`
- `atualizacao.py`

**Roteiro de execução disponível**

## 🚀 Como Executar (roteiro.sh)

Este script executa os seguintes passos:

1. `$profiles = @(`
2. `"corporateprod",`
3. `"arcsandbox",`
4. `"ssrmdev",`
5. `"ssrmsandbox",`
6. `"ssrmprod",`
7. `"corporatedev",`
8. `"sredev",`
9. `"dsstage",`
10. `"dsprod",`
11. `"dsdev",`
12. `"datahubdev",`
13. `"datahubprod",`
14. `"consentdev",`
15. `"consentprod"`

... e mais 88 passos

**Como executar:**
```bash
cd /caminho/para/pasta
bash roteiro.sh
```

## 🐍 Scripts Python

### atualizacao copy.py

**Descrição:** Script Python

**Bibliotecas usadas:** `boto3`, `kubernetes`, `botocore`

**Entrada esperada:** Parâmetros não especificados

**Como usar:**
```bash
python atualizacao copy.py [argumentos]
```

### atualizacao.py

**Descrição:** Script Python

**Bibliotecas usadas:** `boto3`, `kubernetes`, `botocore`

**Entrada esperada:** Parâmetros não especificados

**Como usar:**
```bash
python atualizacao.py [argumentos]
```


## ⚙️ Arquivos de Configuração

**JSON:**
- `ltd.json`

**YAML:**
- `flagger-values.yaml`
- `kiali-ingress-values.yaml`
- `kiali-values.yaml`
- `kube-prometheus-dashboards-values.yaml`
- `kube-prometheus-stack-values.yaml`
- `kubecost-ingress-values.yaml`
- `kubecost-monitoring-values.yaml`
- `kubecost-values.yaml`
- `lixo.yaml`
- `metrics-server-values.yaml`

**Planilhas Excel:**
- `list_pods.xlsx`

## 📋 Pré-requisitos

- Python 3.6+
- Bibliotecas necessárias:
  - `boto3`
  - `botocore`
  - `kubernetes`

**Instalar dependências:**
```bash
pip install -r requirements.txt
```

- `saml2aws` para autenticação AWS
- AWS CLI configurada

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
