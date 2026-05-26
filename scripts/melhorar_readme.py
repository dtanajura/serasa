#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script avançado para gerar READMEs MUITO detalhados
"""

import os
import re
import ast
from pathlib import Path

def ler_arquivo(caminho):
    """Lê um arquivo de texto"""
    try:
        with open(caminho, 'r', encoding='utf-8', errors='ignore') as f:
            return f.read()
    except:
        return None

def analisar_python_detalhado(conteudo_py, nome_arquivo):
    """Análise detalhada de um script Python"""
    
    info = {
        "nome": nome_arquivo,
        "funcoes": [],
        "imports": [],
        "o_que_faz": "Script Python",
        "entrada": [],
        "saida": [],
        "exemplos": []
    }
    
    # Extrai imports
    linhas = conteudo_py.split('\n')
    for linha in linhas[:50]:
        if linha.startswith('import ') or linha.startswith('from '):
            info["imports"].append(linha.strip())
    
    # Procura por docstring do módulo
    match_doc = re.search(r'^"""(.*?)"""', conteudo_py, re.MULTILINE | re.DOTALL)
    if match_doc:
        info["o_que_faz"] = match_doc.group(1).strip()[:200]
    
    # Procura por funções
    funcoes = re.finditer(r'def\s+(\w+)\s*\((.*?)\):\s*"""(.*?)"""', conteudo_py, re.DOTALL)
    for match in funcoes:
        nome_func = match.group(1)
        params = match.group(2)
        docstring = match.group(3).strip()
        
        info["funcoes"].append({
            "nome": nome_func,
            "parametros": params,
            "descricao": docstring[:100]
        })
    
    # Procura por sys.argv
    if "sys.argv" in conteudo_py:
        info["entrada"].append("Argumentos passados via linha de comando")
    
    # Procura por padrões comuns
    if "print(" in conteudo_py:
        info["saida"].append("Resultado impresso no console")
    
    if "boto3" in conteudo_py:
        info["saida"].append("Interação com AWS via Boto3")
    
    if ".xlsx" in conteudo_py or "xlsxwriter" in conteudo_py:
        info["saida"].append("Geração de arquivo Excel")
    
    return info

def gerar_readme_avancado(pasta_path, pasta_nome):
    """Gera README avançado"""
    
    readme = f"# {pasta_nome}\n\n"
    
    # Arquivos
    roteiro_sh = os.path.join(pasta_path, 'roteiro.sh')
    roteiro_txt = os.path.join(pasta_path, 'roteiro.txt')
    
    conteudo_roteiro_sh = None
    conteudo_roteiro_txt = None
    
    if os.path.exists(roteiro_sh):
        conteudo_roteiro_sh = ler_arquivo(roteiro_sh)
    
    if os.path.exists(roteiro_txt):
        conteudo_roteiro_txt = ler_arquivo(roteiro_txt)
    
    # Scripts Python
    scripts_python = []
    for arquivo in sorted(os.listdir(pasta_path)):
        if arquivo.endswith('.py') and not arquivo.startswith('__'):
            caminho_py = os.path.join(pasta_path, arquivo)
            if os.path.isfile(caminho_py):
                conteudo_py = ler_arquivo(caminho_py)
                if conteudo_py:
                    info = analisar_python_detalhado(conteudo_py, arquivo)
                    scripts_python.append(info)
    
    # SEÇÃO 1: VISÃO GERAL
    readme += "## 📌 Visão Geral\n\n"
    
    if scripts_python:
        nomes_scripts = ', '.join([f"`{s['nome']}`" for s in scripts_python])
        readme += f"**Scripts Python:** {nomes_scripts}\n\n"
    
    if conteudo_roteiro_sh:
        readme += "**Roteiro:** `roteiro.sh`\n\n"
    elif conteudo_roteiro_txt:
        readme += "**Roteiro:** `roteiro.txt`\n\n"
    
    # SEÇÃO 2: ROTEIRO
    if conteudo_roteiro_sh:
        readme += "## 🚀 Roteiro de Execução\n\n"
        readme += "Este script executa automaticamente os seguintes passos:\n\n"
        
        linhas = conteudo_roteiro_sh.split('\n')
        passos = []
        
        for i, linha in enumerate(linhas):
            linha = linha.strip()
            if linha and not linha.startswith('#'):
                comando = linha.split('#')[0].strip()
                if comando and len(comando) > 3:
                    passos.append(comando)
        
        for i, passo in enumerate(passos[:25], 1):
            if 'python' in passo.lower():
                readme += f"{i}. Executa: `{passo[:80]}`\n"
            elif 'login' in passo.lower():
                readme += f"{i}. Autenticação: `{passo[:80]}`\n"
            else:
                readme += f"{i}. `{passo[:80]}`\n"
        
        if len(passos) > 25:
            readme += f"\n... mais {len(passos) - 25} passos ...\n"
        
        readme += f"\n**Total: {len(passos)} passos**\n\n"
        
        readme += "**Como executar:**\n"
        readme += "```bash\n"
        readme += "bash roteiro.sh\n"
        readme += "```\n\n"
    
    elif conteudo_roteiro_txt:
        readme += "## 📋 Instruções\n\n"
        linhas = conteudo_roteiro_txt.split('\n')
        for i, linha in enumerate([l.strip() for l in linhas if l.strip()][:15], 1):
            readme += f"{i}. {linha}\n"
        readme += "\n"
    
    # SEÇÃO 3: SCRIPTS PYTHON
    if scripts_python:
        readme += "## 🐍 Scripts Python\n\n"
        
        for script in scripts_python:
            readme += f"### `{script['nome']}`\n\n"
            readme += f"**Função:** {script['o_que_faz']}\n\n"
            
            if script["funcoes"]:
                readme += "**Funções principais:**\n"
                for func in script["funcoes"][:3]:
                    readme += f"- **{func['nome']}**: {func['descricao']}\n"
                readme += "\n"
            
            readme += "**Como usar:**\n"
            readme += "```bash\n"
            readme += f"python {script['nome']}\n"
            readme += "```\n\n"
            
            if script["imports"]:
                readme += "**Bibliotecas:**\n"
                unique_imports = set()
                for imp in script["imports"]:
                    match = re.search(r'(import|from)\s+(\w+)', imp)
                    if match:
                        unique_imports.add(match.group(2))
                
                for imp in sorted(unique_imports):
                    if imp not in ['sys', 'os', 're', 'json']:
                        readme += f"- `{imp}`\n"
                readme += "\n"
            
            if script["saida"]:
                readme += "**Retorna:**\n"
                for saida in script["saida"]:
                    readme += f"- {saida}\n"
                readme += "\n"
    
    # SEÇÃO 4: PRÉ-REQUISITOS
    readme += "## 📋 Pré-requisitos\n\n"
    
    if scripts_python:
        readme += "**Python 3.6+** com bibliotecas:\n"
        readme += "```bash\n"
        readme += "pip install boto3 pandas openpyxl\n"
        readme += "```\n\n"
    
    roteiro_all = (conteudo_roteiro_sh or "") + (conteudo_roteiro_txt or "")
    
    if "saml2aws" in roteiro_all:
        readme += "**Autenticação:**\n"
        readme += "- `saml2aws` instalado\n"
        readme += "- Perfis AWS configurados\n"
        readme += "- `saml2aws login -a <account>`\n\n"
    
    if "aws" in roteiro_all.lower():
        readme += "**AWS:**\n"
        readme += "- AWS CLI v2\n"
        readme += "- Credenciais configuradas\n"
        readme += "- Permissões apropriadas\n\n"
    
    # SEÇÃO 5: EXEMPLOS
    readme += "## 💡 Exemplos\n\n"
    
    if scripts_python:
        for script in scripts_python[:2]:
            readme += f"**Usar {script['nome']}:**\n"
            readme += "```bash\n"
            readme += f"python {script['nome']}\n"
            readme += "```\n\n"
    
    readme += "**Executar roteiro completo:**\n"
    readme += "```bash\n"
    if os.path.exists(os.path.join(pasta_path, 'roteiro.sh')):
        readme += "bash roteiro.sh\n"
    readme += "```\n\n"
    
    # SEÇÃO 6: TROUBLESHOOTING
    readme += "## 🐛 Troubleshooting\n\n"
    readme += "| Erro | Solução |\n"
    readme += "|------|----------|\n"
    readme += "| Erro de autenticação | `saml2aws login -a <account>` |\n"
    readme += "| ModuleNotFoundError | `pip install boto3` |\n"
    readme += "| Acesso negado | Verificar permissões IAM |\n\n"
    
    # SEÇÃO 7: OBSERVAÇÕES
    readme += "## ⚠️ Importante\n\n"
    readme += "- ✅ Testar em DEV antes de PROD\n"
    readme += "- ✅ Revisar scripts antes de executar\n"
    readme += "- ✅ Fazer backup de dados sensíveis\n"
    readme += "- ❌ Nunca commitar credenciais AWS\n\n"
    
    readme += "---\n"
    readme += "*Última atualização: 2026-05-26*\n"
    
    return readme

# Processar pastas principais
basepath = "/sessions/determined-confident-dirac/mnt/serasa"

PASTAS = [
    "Listar Roles dos Node Groups",
    "inventario datahub",
    "Rotina Lambda",
    "Lista certificados",
    "Vulnerabilidades - 2",
    "Migração de contas DEV-HUB",
    "Onboard contas positivo e negativo",
    "inventario",
]

print("Gerando READMEs detalhados...\n")

for pasta_nome in PASTAS:
    pasta_path = os.path.join(basepath, pasta_nome)
    
    if os.path.isdir(pasta_path):
        try:
            readme_content = gerar_readme_avancado(pasta_path, pasta_nome)
            readme_path = os.path.join(pasta_path, "README.md")
            
            with open(readme_path, 'w', encoding='utf-8') as f:
                f.write(readme_content)
            
            print(f"✅ {pasta_nome}")
        except Exception as e:
            print(f"⚠️  {pasta_nome}: {str(e)[:50]}")

print("\n✅ READMEs detalhados criados!")
