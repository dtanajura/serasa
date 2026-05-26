#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script para gerar README.md em cada pasta (usando nomes atuais)
"""

import os
from pathlib import Path

# Mapa de pastas ATUAIS com descrições
PASTAS_ATUAIS = {
    "AWS CLI Diversos": {
        "titulo": "AWS CLI - Scripts Diversos",
        "descricao": "Coleção de scripts utilizando AWS CLI para diferentes tarefas",
    },
    "Ambiente LAB": {
        "titulo": "Ambiente de Laboratório DEV Experience",
        "descricao": "Setup e documentação do ambiente de laboratório para experiência de desenvolvedor",
    },
    "ambiente lab - dev experience": {
        "titulo": "Ambiente Lab DEV Experience (consolidar)",
        "descricao": "NOTA: Esta pasta deve ser consolidada com 'Ambiente LAB'",
    },
    "Hackaton": {
        "titulo": "Hackathon Nike",
        "descricao": "Documentação e diagramas do projeto Hackathon Nike",
    },
    "Levantamento do ambiente": {
        "titulo": "Levantamento do Ambiente",
        "descricao": "Documentação do levantamento geral do ambiente AWS",
    },
    "Lista certificados": {
        "titulo": "AWS ACM - Gestão de Certificados",
        "descricao": "Scripts para listar e gerenciar certificados no AWS Certificate Manager",
    },
    "Listar Roles dos Node Groups": {
        "titulo": "EKS Node Groups - Listar Roles",
        "descricao": "Script para listar roles dos Node Groups em clusters EKS",
    },
    "Migracao-mongo": {
        "titulo": "Migração MongoDB",
        "descricao": "Documentação e configuração para migração de MongoDB",
    },
    "Migração de contas DEV-HUB": {
        "titulo": "Onboarding DevHub - Migração de Contas",
        "descricao": "Processo de migração e onboarding de contas DEV-HUB",
    },
    "Monitoramento eec-aws-br-nike-ss-sandbox": {
        "titulo": "Monitoramento - Sandbox",
        "descricao": "Configuração de monitoramento para conta sandbox",
    },
    "Onboard contas positivo e negativo": {
        "titulo": "Onboarding Contas Positivo e Negativo",
        "descricao": "Onboarding e configuração de contas Positivo e Negativo",
    },
    "Onboarding conta SRE DEV": {
        "titulo": "Onboarding SRE - Conta DEV",
        "descricao": "Onboarding da conta SRE DEV com configurações específicas",
    },
    "Onboarding contas devhub": {
        "titulo": "Onboarding DevHub - Completo",
        "descricao": "Documentação completa do onboarding de contas DevHub",
    },
    "Permissão BUUserForDevSecOpsPiaaS": {
        "titulo": "Permissões - DevSecOps PiaaS",
        "descricao": "Configuração de permissões para usuário BUUserForDevSecOpsPiaaS",
    },
    "Pinot": {
        "titulo": "Pinot - Analytics",
        "descricao": "Configuração e deployment do Pinot Analytics",
    },
    "Remover cluster eks": {
        "titulo": "Remoção EKS Cluster",
        "descricao": "Scripts para remover cluster EKS de forma segura",
    },
    "Remover tudo": {
        "titulo": "Limpeza Completa - Contas",
        "descricao": "Script para limpeza completa de contas AWS",
    },
    "Rotina Lambda": {
        "titulo": "Lambda - Automação",
        "descricao": "Rotinas Lambda para automação de tagging e gerenciamento",
    },
    "Solicitação de certificados": {
        "titulo": "Solicitação de Certificados",
        "descricao": "Processo de solicitação e gerenciamento de certificados",
    },
    "Tasks": {
        "titulo": "Tasks - Rastreamento",
        "descricao": "Sistema de rastreamento de tarefas por equipe",
    },
    "Tratamento Mongo": {
        "titulo": "Tratamento MongoDB",
        "descricao": "Documentação de tratamento e operações em MongoDB",
    },
    "Vulnerabilidades - 2": {
        "titulo": "Análise de Vulnerabilidades",
        "descricao": "Análise e relatórios de vulnerabilidades",
    },
    "_outras tarefas": {
        "titulo": "Tarefas Diversas",
        "descricao": "Coleção de tarefas diversas não categorizadas",
    },
    "atualização cliente zabbix": {
        "titulo": "Atualização Zabbix Client",
        "descricao": "Procedimento de atualização de cliente Zabbix",
    },
    "backup": {
        "titulo": "Backup - Configuração",
        "descricao": "Configuração de backup para recursos AWS",
    },
    "inventario": {
        "titulo": "Inventário - Geral",
        "descricao": "Inventário geral de recursos AWS",
    },
    "inventario datahub": {
        "titulo": "Inventário DataHub - Tags",
        "descricao": "Inventário específico para DataHub com tagging",
    },
    "lens": {
        "titulo": "Lens - Kubernetes UI",
        "descricao": "Configuração do Lens para visualização Kubernetes",
    },
    "levantamento volumes": {
        "titulo": "Levantamento Volumes EBS",
        "descricao": "Levantamento e catalogação de volumes EBS",
    },
    "ligar e desligar eks": {
        "titulo": "EKS - Start/Stop Script",
        "descricao": "Script para ligar e desligar clusters EKS",
    },
    "negativos-privados": {
        "titulo": "Contas Negativo - Privadas",
        "descricao": "Configuração de contas Negativo com subredes privadas",
    },
    "permissões para deployments": {
        "titulo": "Permissões - Deployment",
        "descricao": "Configuração de permissões específicas para deployments",
    },
    "rev_labs": {
        "titulo": "Review - Laboratórios",
        "descricao": "Revisão de ambientes de laboratório",
    },
    "roteiros": {
        "titulo": "Roteiros - Centralizados",
        "descricao": "Centralização de roteiros e procedimentos",
    },
    "sagemaker": {
        "titulo": "SageMaker - Machine Learning",
        "descricao": "Configuração e experimenta com SageMaker",
    },
    "system manager": {
        "titulo": "AWS Systems Manager",
        "descricao": "Configuração e uso do Systems Manager",
    },
    "terragrunt": {
        "titulo": "Terragrunt - Infrastructure as Code",
        "descricao": "Configuração de Terragrunt para IaC",
    },
    "usuario BUUserForPositivoMercantil": {
        "titulo": "Usuário Positivo - Mercantil",
        "descricao": "Configuração de usuário para ambiente Positivo Mercantil",
    },
    "vulnerabilidades": {
        "titulo": "Análise Vulnerabilidades - v1",
        "descricao": "Primeira versão da análise de vulnerabilidades",
    },
    "zabbix": {
        "titulo": "Zabbix - Monitoring",
        "descricao": "Configuração completa do Zabbix para monitoramento",
    },
}

def gerar_readme(pasta_info):
    """Gera um README.md para a pasta especificada"""
    
    titulo = pasta_info.get("titulo", "Projeto")
    descricao = pasta_info.get("descricao", "")
    
    readme_content = f"""# {titulo}

## 📌 Descrição

{descricao}

## 🎯 Como Usar

1. Verifique os arquivos nesta pasta
2. Consulte o arquivo `roteiro.sh` ou `roteiro.txt` para instruções específicas
3. Leia os comentários nos scripts para entender o fluxo

## 📝 Arquivos Importantes

- Procure por arquivos `roteiro.sh` ou `roteiro.txt`
- Verifique scripts com extensão `.py` ou `.sh`
- Consulte documentação em `.docx` ou `.xlsx`

## 📊 Status

- Última atualização: 2026-05-26

## ⚠️ Notas Importantes

- Este repositório está sendo reorganizado
- Cada pasta terá sua documentação melhorada
- Para dúvidas, consulte os roteiros específicos

---

*README gerado automaticamente - Atualize conforme necessário*
"""
    
    return readme_content

def main():
    """Função principal"""
    print("Gerando READMEs para todas as pastas (nomes atuais)...")
    print("=" * 50)
    
    criados = 0
    ja_existem = 0
    erros = 0
    
    for pasta_nome, pasta_info in PASTAS_ATUAIS.items():
        readme_path = f"/sessions/determined-confident-dirac/mnt/serasa/{pasta_nome}/README.md"
        
        # Verificar se já existe
        if os.path.exists(readme_path):
            print(f"⏭️  Pulado (já existe): {pasta_nome}/README.md")
            ja_existem += 1
            continue
        
        try:
            # Verificar se a pasta existe
            pasta_path = f"/sessions/determined-confident-dirac/mnt/serasa/{pasta_nome}"
            if not os.path.isdir(pasta_path):
                print(f"❌ Pasta não encontrada: {pasta_nome}")
                erros += 1
                continue
            
            content = gerar_readme(pasta_info)
            
            with open(readme_path, 'w', encoding='utf-8') as f:
                f.write(content)
            
            print(f"✅ Criado: {pasta_nome}/README.md")
            criados += 1
            
        except Exception as e:
            print(f"❌ Erro ao criar {pasta_nome}: {str(e)}")
            erros += 1
    
    print("=" * 50)
    print(f"✅ Criados: {criados}")
    print(f"⏭️  Já existem: {ja_existem}")
    print(f"❌ Erros: {erros}")
    print(f"📊 Total processado: {len(PASTAS_ATUAIS)}")

if __name__ == "__main__":
    main()
