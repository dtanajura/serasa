# Ambiente LAB

## 📌 Descrição

Pasta: `Ambiente LAB`

**Scripts Python encontrados:**
- `teste.py`

**Roteiro de execução disponível**

## 📋 Roteiro de Execução

Passos a serem executados:

1. # para provisionamento do ambiente EKS, ver os seguintes links:
2. https://pages.experian.com/pages/viewpage.action?pageId=1081626313
3. Ver pre-reqs para provisinameto do ambiente EKS:
4. https://pages.experian.com/pages/viewpage.action?pageId=1081223498
5. Raissa - ultima requisição do Cristiano para criação das contas AWS
6. Para atvidade de Maturidade de Cloud:
7. Contas:
8. eec-aws-br-eits-devhub-dev
9. eec-aws-br-eits-devhub-prod
10. eec-aws-br-eits-devhub-sandbox
11. eec-aws-br-eits-devhub-test
12. Link do portal:
13. https://app.powerbi.com/groups/me/apps/782b0433-4239-4b7e-afd1-d2af40b765e2/reports/a8f8a919-90d4-4a61-9568-7744246ce8e0/ReportSection5c55b2d5381a302e1460?ctid=be67623c-1932-42a6-9d24-6c359fe5ea71&experience=power-bi
14. Documentação do portal:
15. https://pages.experian.com/display/SC/Cloud+Maturity+Score

## 🐍 Scripts Python

### teste.py

**Descrição:** Script Python

**Bibliotecas usadas:** `boto3`

**Entrada esperada:** Parâmetros não especificados

**Como usar:**
```bash
python teste.py [argumentos]
```


## ⚙️ Arquivos de Configuração

**JSON:**
- `teste.json`

**Documentação Word:**
- `Implantação ambiente de LAB para o DEV Experience.docx`
- `Roteiro spike Bitbucket.docx`
- `Roteiro.docx`

## 📋 Pré-requisitos

- Python 3.6+
- Bibliotecas necessárias:
  - `boto3`

**Instalar dependências:**
```bash
pip install -r requirements.txt
```

- AWS CLI configurada
- Credenciais AWS com permissões apropriadas

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
