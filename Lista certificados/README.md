# Lista certificados

## 📌 Visão Geral

**Scripts Python:** `acm.py`

## 🐍 Scripts Python

### `acm.py`

**Função:** Script Python

**Como usar:**
```bash
python acm.py
```

**Bibliotecas:**
- `argparse`
- `boto3`
- `botocore`
- `datetime`
- `pandas`
- `typing`

**Retorna:**
- Resultado impresso no console
- Interação com AWS via Boto3
- Geração de arquivo Excel

## 📋 Pré-requisitos

**Python 3.6+** com bibliotecas:
```bash
pip install boto3 pandas openpyxl
```

## 💡 Exemplos

**Usar acm.py:**
```bash
python acm.py
```

**Executar roteiro completo:**
```bash
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
