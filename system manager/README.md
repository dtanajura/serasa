# system manager

## 📌 Descrição

Pasta: `system manager`

**Scripts Python encontrados:**
- `coleta.py`
- `teste coleta.py`

## 🐍 Scripts Python

### coleta.py

**Descrição:** # INSERT INTO metricas (instance_id, cpu_usage, mem_usage, disk_usage, account_id, coleta_horario)
        # VALUES (%s, %s, %s, %s, %s, %s)
        #

**Bibliotecas usadas:** `boto3`, `psycopg2`, `os`, `time`, `datetime`, `boto3`, `psycopg2`, `os`, `time`, `datetime`

**Entrada esperada:** Parâmetros não especificados

**Exemplo de uso:**
```bash
python coleta.py Uso de Disco:
```

### teste coleta.py

**Descrição:** Script Python

**Bibliotecas usadas:** `boto3`, `psycopg2`, `os`

**Entrada esperada:** Parâmetros não especificados

**Exemplo de uso:**
```bash
python teste coleta.py Uso de Disco:
```


## ⚙️ Arquivos de Configuração

**JSON:**
- `eventbridge_target.json`
- `output.json`
- `rotina.json`

## 📋 Pré-requisitos

- Python 3.6+
- Bibliotecas necessárias:
  - `boto3`
  - `datetime`
  - `psycopg2`
  - `time`

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
