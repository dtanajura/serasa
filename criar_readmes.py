#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script para gerar README.md em cada pasta do repositório SERASA
"""

import os
import json
from pathlib import Path

# Mapa de pastas com descrições
PASTAS = {
    "01-AWS-CLI-Diversos": {
        "titulo": "AWS CLI - Scripts Diversos",
        "descricao": "Coleção de scripts utilizando AWS CLI para diferentes tarefas",
        "objetivo": "Realizar operações diversas na AWS via CLI",
        "status": "COMPLETADO",
        "tecnologias": ["AWS CLI", "Bash"],
        "arquivos_importantes": ["testes-sgs.sh"],
    },
    "02-Ambiente-LAB-DEV-Experience": {
        "titulo": "Ambiente de Laboratório para DEV Experience",
        "descricao": "Setup e documentação do ambiente de laboratório para experiência de desenvolvedor",
        "objetivo": "Criar um ambiente controlado para testes e desenvolvimento",
        "status": "COMPLETADO",
        "tecnologias": ["AWS", "Kubernetes", "Terraform", "Bitbucket"],
        "arquivos_importantes": ["Implantação ambiente de LAB para o DEV Experience.docx", "roteiro.sh"],
    },
    "03-Hackathon-Nike": {
        "titulo": "Hackathon Nike",
        "descricao": "Documentação e diagramas do projeto Hackathon Nike",
        "objetivo": "Organizar e documentar a arquitetura da ingestão de dados cross-account",
        "status": "COMPLETADO",
        "tecnologias": ["Draw.io", "AWS", "Data Pipeline"],
        "arquivos_importantes": ["hackathon.drawio", "ingestão cross account.drawio"],
    },
    "04-Levantamento-Ambiente": {
        "titulo": "Levantamento do Ambiente",
        "descricao": "Documentação do levantamento geral do ambiente AWS",
        "objetivo": "Realizar levantamento completo de recursos e configuração",
        "status": "COMPLETADO",
        "tecnologias": ["AWS", "Documentação"],
        "arquivos_importantes": ["Roteiro de levantamento do ambiente.docx"],
    },
    "05-AWS-ACM-Certificados": {
        "titulo": "AWS ACM - Gestão de Certificados",
        "descricao": "Scripts para listar e gerenciar certificados no AWS Certificate Manager",
        "objetivo": "Automatizar listagem e validação de certificados ACM",
        "status": "COMPLETADO",
        "tecnologias": ["Python", "AWS ACM", "Boto3"],
        "arquivos_importantes": ["acm.py", "acm_certificates.xlsx"],
    },
    "06-EKS-Node-Groups-Roles": {
        "titulo": "EKS Node Groups - Listar Roles",
        "descricao": "Script para listar roles dos Node Groups em clusters EKS",
        "objetivo": "Inventariar roles IAM atribuídas aos node groups",
        "status": "COMPLETADO",
        "tecnologias": ["Python", "AWS EKS", "IAM"],
        "arquivos_importantes": ["lista.py", "roteiro.sh"],
    },
    "07-Migracao-MongoDB": {
        "titulo": "Migração MongoDB",
        "descricao": "Documentação e configuração para migração de MongoDB",
        "objetivo": "Realizar migração de dados MongoDB para nova infra",
        "status": "PLANEJAMENTO",
        "tecnologias": ["MongoDB", "AWS DMS", "Terraform"],
        "arquivos_importantes": ["DMS.png", "Terraform/"],
    },
    "08-Onboarding-DevHub-Migracao": {
        "titulo": "Onboarding DevHub - Migração de Contas",
        "descricao": "Processo de migração e onboarding de contas DEV-HUB",
        "objetivo": "Migrar e configurar contas DEV-HUB com automações",
        "status": "COMPLETADO",
        "tecnologias": ["AWS", "Bash", "JSON", "CloudFormation"],
        "arquivos_importantes": ["onboarding.sh", "tagging.sh", "roteiro.sh"],
    },
    "09-Monitoramento-Sandbox": {
        "titulo": "Monitoramento - Sandbox",
        "descricao": "Configuração de monitoramento para conta sandbox",
        "objetivo": "Setup de monitoramento para ambiente de testes",
        "status": "COMPLETADO",
        "tecnologias": ["AWS CloudWatch", "Monitoring"],
        "arquivos_importantes": ["roteiro.sh"],
    },
    "10-Onboarding-Positivo-Negativo": {
        "titulo": "Onboarding Contas Positivo e Negativo",
        "descricao": "Onboarding e configuração de contas Positivo e Negativo",
        "objetivo": "Setup completo de ambientes Positivo e Negativo",
        "status": "COMPLETADO",
        "tecnologias": ["AWS", "IAM", "JSON", "Bash"],
        "arquivos_importantes": ["roteiro.sh", "provision-parameters-*.json"],
    },
    "11-Onboarding-SRE-DEV": {
        "titulo": "Onboarding SRE - Conta DEV",
        "descricao": "Onboarding da conta SRE DEV com configurações específicas",
        "objetivo": "Configurar ambiente para SRE em desenvolvimento",
        "status": "COMPLETADO",
        "tecnologias": ["AWS", "Systems Manager", "Bash"],
        "arquivos_importantes": ["roteiro-prd.sh", "bastion-sredev.pem"],
    },
    "12-Onboarding-DevHub-Completo": {
        "titulo": "Onboarding DevHub - Completo",
        "descricao": "Documentação completa do onboarding de contas DevHub",
        "objetivo": "Centralizar processo de onboarding para devhub",
        "status": "COMPLETADO",
        "tecnologias": ["AWS", "DevHub", "Documentação"],
        "arquivos_importantes": ["roteiro.txt", "subpastas de ambientes"],
    },
    "13-Permissoes-DevSecOps-PiaaS": {
        "titulo": "Permissões - DevSecOps PiaaS",
        "descricao": "Configuração de permissões para usuário BUUserForDevSecOpsPiaaS",
        "objetivo": "Setup de políticas IAM para DevSecOps",
        "status": "COMPLETADO",
        "tecnologias": ["AWS IAM", "JSON", "Bash"],
        "arquivos_importantes": ["policy.json", "roteiro.sh"],
    },
    "14-Pinot-Analytics": {
        "titulo": "Pinot - Analytics",
        "descricao": "Configuração e deployment do Pinot Analytics",
        "objetivo": "Setup de plataforma de analytics com Pinot",
        "status": "EM PROGRESSO",
        "tecnologias": ["Pinot", "Kubernetes", "YAML"],
        "arquivos_importantes": ["values.yaml", "roteiro.sh"],
    },
    "15-Remocao-EKS-Cluster": {
        "titulo": "Remoção EKS Cluster",
        "descricao": "Scripts para remover cluster EKS de forma segura",
        "objetivo": "Automação de remoção de cluster EKS",
        "status": "COMPLETADO",
        "tecnologias": ["AWS EKS", "Bash", "Cleanup"],
        "arquivos_importantes": ["roteiro.sh", "replication-config.json"],
    },
    "16-Limpeza-Completa-Contas": {
        "titulo": "Limpeza Completa - Contas",
        "descricao": "Script para limpeza completa de contas AWS",
        "objetivo": "Remover todos os recursos de uma conta (cleanup total)",
        "status": "COMPLETADO",
        "tecnologias": ["AWS CLI", "Bash", "Cleanup"],
        "arquivos_importantes": ["roteiro.sh"],
    },
    "17-Lambda-Automation": {
        "titulo": "Lambda - Automação",
        "descricao": "Rotinas Lambda para automação de tagging e gerenciamento",
        "objetivo": "Implementar automações serverless com Lambda",
        "status": "COMPLETADO",
        "tecnologias": ["Python", "AWS Lambda", "IAM"],
        "arquivos_importantes": ["lambda.py", "tag-teste-profile.py", "roteiro.sh"],
    },
    "18-Solicitacao-Certificados": {
        "titulo": "Solicitação de Certificados",
        "descricao": "Processo de solicitação e gerenciamento de certificados",
        "objetivo": "Documentar workflow de certificados ACM",
        "status": "COMPLETADO",
        "tecnologias": ["AWS ACM", "Certificados"],
        "arquivos_importantes": ["subpastas: DEVHUB, Lab01"],
    },
    "19-Tasks-Rastreamento": {
        "titulo": "Tasks - Rastreamento",
        "descricao": "Sistema de rastreamento de tarefas por equipe",
        "objetivo": "Organizar e rastrear tarefas por área (Mercantil, Plataforma, Warriors)",
        "status": "EM PROGRESSO",
        "tecnologias": ["Documentação", "Task Management"],
        "arquivos_importantes": ["subpastas: Mercantil, Plataforma, Warriors"],
    },
    "20-Tratamento-MongoDB": {
        "titulo": "Tratamento MongoDB",
        "descricao": "Documentação de tratamento e operações em MongoDB",
        "objetivo": "Centralizar processos de tratamento MongoDB",
        "status": "EM PROGRESSO",
        "tecnologias": ["MongoDB", "YAML", "Bash"],
        "arquivos_importantes": ["mongodb-uat-mongod-conf.yaml"],
    },
    "21-Analise-Vulnerabilidades": {
        "titulo": "Análise de Vulnerabilidades",
        "descricao": "Análise e relatórios de vulnerabilidades",
        "objetivo": "Identificar e documentar vulnerabilidades",
        "status": "COMPLETADO",
        "tecnologias": ["SQL", "Bash", "Excel"],
        "arquivos_importantes": ["resultado.xlsx", "queries.sql", "roteiro.sh"],
    },
    "22-Tarefas-Diversas": {
        "titulo": "Tarefas Diversas",
        "descricao": "Coleção de tarefas diversas não categorizadas",
        "objetivo": "Armazenar tarefas miscelâneas",
        "status": "VÁRIOS",
        "tecnologias": ["Diversos"],
        "arquivos_importantes": ["Verificar conteúdo"],
    },
    "23-Atualizacao-Zabbix-Client": {
        "titulo": "Atualização Zabbix Client",
        "descricao": "Procedimento de atualização de cliente Zabbix",
        "objetivo": "Documentar processo de atualização",
        "status": "COMPLETADO",
        "tecnologias": ["Zabbix", "Monitoring"],
        "arquivos_importantes": ["atualiza.txt"],
    },
    "24-Backup-Configuration": {
        "titulo": "Backup - Configuração",
        "descricao": "Configuração de backup para recursos AWS",
        "objetivo": "Setup de política e estratégia de backup",
        "status": "PLANEJAMENTO",
        "tecnologias": ["AWS Backup", "JSON"],
        "arquivos_importantes": ["backup-plan.json", "comandos.txt"],
    },
    "25-Inventario-Geral": {
        "titulo": "Inventário - Geral",
        "descricao": "Inventário geral de recursos AWS",
        "objetivo": "Manter registry de todos os recursos",
        "status": "ATIVO",
        "tecnologias": ["Python", "AWS", "Boto3"],
        "arquivos_importantes": ["inventory.py", "subpastas: automation, aws-inventory"],
    },
    "26-Inventario-DataHub-Tags": {
        "titulo": "Inventário DataHub - Tags",
        "descricao": "Inventário específico para DataHub com tagging",
        "objetivo": "Gerenciar recursos DataHub com tags consistentes",
        "status": "COMPLETADO",
        "tecnologias": ["Python", "AWS", "Excel", "JSON"],
        "arquivos_importantes": ["grava_tags.py", "invent_excel.py", "arquivos .xlsx"],
    },
    "27-Lens-Kubernetes-UI": {
        "titulo": "Lens - Kubernetes UI",
        "descricao": "Configuração do Lens para visualização Kubernetes",
        "objetivo": "Setup de ferramenta de UI para K8s",
        "status": "COMPLETADO",
        "tecnologias": ["Kubernetes", "Lens", "UI"],
        "arquivos_importantes": ["Verificar conteúdo"],
    },
    "28-Levantamento-Volumes-EBS": {
        "titulo": "Levantamento Volumes EBS",
        "descricao": "Levantamento e catalogação de volumes EBS",
        "objetivo": "Inventariar todos os volumes EBS em uso",
        "status": "COMPLETADO",
        "tecnologias": ["AWS EBS", "Levantamento"],
        "arquivos_importantes": ["Verificar conteúdo"],
    },
    "29-EKS-Start-Stop-Script": {
        "titulo": "EKS - Start/Stop Script",
        "descricao": "Script para ligar e desligar clusters EKS",
        "objetivo": "Automação de start/stop para reduzir custos",
        "status": "COMPLETADO",
        "tecnologias": ["Bash", "AWS CLI", "EKS"],
        "arquivos_importantes": ["Verificar scripts"],
    },
    "30-Contas-Negativo-Privadas": {
        "titulo": "Contas Negativo - Privadas",
        "descricao": "Configuração de contas Negativo com subredes privadas",
        "objetivo": "Setup de contas com isolamento de rede",
        "status": "COMPLETADO",
        "tecnologias": ["AWS VPC", "Private Networks"],
        "arquivos_importantes": ["Verificar conteúdo"],
    },
    "31-Permissoes-Deployment": {
        "titulo": "Permissões - Deployment",
        "descricao": "Configuração de permissões específicas para deployments",
        "objetivo": "Setup de IAM para pipelines CI/CD",
        "status": "COMPLETADO",
        "tecnologias": ["AWS IAM", "CI/CD"],
        "arquivos_importantes": ["Verificar conteúdo"],
    },
    "32-Review-Laboratorios": {
        "titulo": "Review - Laboratórios",
        "descricao": "Revisão de ambientes de laboratório",
        "objetivo": "Validar e documentar labs",
        "status": "EM PROGRESSO",
        "tecnologias": ["Documentação", "Review"],
        "arquivos_importantes": ["Verificar conteúdo"],
    },
    "33-Roteiros-Centralizados": {
        "titulo": "Roteiros - Centralizados",
        "descricao": "Centralização de roteiros e procedimentos",
        "objetivo": "Organizar todos os roteiros em um único lugar",
        "status": "EM PROGRESSO",
        "tecnologias": ["Documentação", "Bash"],
        "arquivos_importantes": ["Verificar conteúdo"],
    },
    "34-SageMaker-ML": {
        "titulo": "SageMaker - Machine Learning",
        "descricao": "Configuração e experimenta com SageMaker",
        "objetivo": "Setup de plataforma ML com SageMaker",
        "status": "PLANEJAMENTO",
        "tecnologias": ["AWS SageMaker", "ML"],
        "arquivos_importantes": ["Verificar conteúdo"],
    },
    "35-AWS-Systems-Manager": {
        "titulo": "AWS Systems Manager",
        "descricao": "Configuração e uso do Systems Manager",
        "objetivo": "Gerenciar recursos via Systems Manager",
        "status": "COMPLETADO",
        "tecnologias": ["AWS Systems Manager", "Parameter Store"],
        "arquivos_importantes": ["Verificar conteúdo"],
    },
    "36-Terragrunt-IaC": {
        "titulo": "Terragrunt - Infrastructure as Code",
        "descricao": "Configuração de Terragrunt para IaC",
        "objetivo": "Implementar IaC com Terragrunt",
        "status": "EM PROGRESSO",
        "tecnologias": ["Terragrunt", "Terraform", "IaC"],
        "arquivos_importantes": ["Verificar conteúdo"],
    },
    "37-Usuario-Positivo-Mercantil": {
        "titulo": "Usuário Positivo - Mercantil",
        "descricao": "Configuração de usuário para ambiente Positivo Mercantil",
        "objetivo": "Setup de acesso para usuários em Positivo",
        "status": "COMPLETADO",
        "tecnologias": ["AWS IAM", "User Management"],
        "arquivos_importantes": ["Verificar conteúdo"],
    },
    "38-Analise-Vulnerabilidades-v1": {
        "titulo": "Análise Vulnerabilidades - v1",
        "descricao": "Primeira versão da análise de vulnerabilidades",
        "objetivo": "Documento inicial de análise de vulnerabilidades",
        "status": "COMPLETADO",
        "tecnologias": ["Security Analysis"],
        "arquivos_importantes": ["Verificar conteúdo"],
    },
    "39-Zabbix-Monitoring": {
        "titulo": "Zabbix - Monitoring",
        "descricao": "Configuração completa do Zabbix para monitoramento",
        "objetivo": "Setup de plataforma de monitoramento Zabbix",
        "status": "ATIVO",
        "tecnologias": ["Zabbix", "Monitoring"],
        "arquivos_importantes": ["Verificar conteúdo"],
    },
}

def gerar_readme(pasta_num, pasta_info):
    """Gera um README.md para a pasta especificada"""
    
    titulo = pasta_info.get("titulo", f"Projeto {pasta_num}")
    descricao = pasta_info.get("descricao", "")
    objetivo = pasta_info.get("objetivo", "")
    status = pasta_info.get("status", "")
    tecnologias = pasta_info.get("tecnologias", [])
    arquivos = pasta_info.get("arquivos_importantes", [])
    
    readme_content = f"""# {titulo}

## 📌 Descrição

{descricao}

## 🎯 Objetivo

{objetivo}

## 📊 Status

- **Status**: `{status}`
- **Data**: 2026-05-26

## 🔧 Tecnologias

"""
    
    for tech in tecnologias:
        readme_content += f"- {tech}\n"
    
    readme_content += f"""
## 📁 Estrutura de Arquivos

"""
    
    if arquivos:
        for arquivo in arquivos:
            readme_content += f"- `{arquivo}`\n"
    else:
        readme_content += "```\nVerifique os arquivos presentes nesta pasta\n```\n"
    
    readme_content += f"""
## 🚀 Como Usar

### Pré-requisitos

- Credenciais AWS configuradas
- CLI tools necessárias instaladas

### Execução

Consulte o arquivo `roteiro.sh` ou `roteiro.txt` para instruções específicas.

## 📋 Próximos Passos

[Adicionar próximos passos conforme necessário]

## 📞 Observações

- Última atualização: 2026-05-26
- Revisar periodicamente para manter atualizado

---

*Gerado automaticamente - Atualize conforme necessário*
"""
    
    return readme_content

def main():
    """Função principal"""
    print("Gerando READMEs para todas as pastas...")
    
    for pasta_num, pasta_info in PASTAS.items():
        readme_path = f"{pasta_num}/README.md"
        content = gerar_readme(pasta_num, pasta_info)
        
        with open(readme_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        print(f"✅ Criado: {readme_path}")
    
    print(f"\n✅ Total: {len(PASTAS)} READMEs criados!")

if __name__ == "__main__":
    main()
