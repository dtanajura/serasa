#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Script para gerar READMEs detalhados analisando roteiros e scripts
"""

import os
import re
from pathlib import Path

def ler_arquivo(caminho):
    """Lê um arquivo de texto"""
    try:
        with open(caminho, 'r', encoding='utf-8', errors='ignore') as f:
            return f.read()
    except:
        return None

def extrair_info_python(conteudo_py):
    """Extrai informações de um script Python"""
    info = {
        "descricao": "Script Python",
        "entrada": "Parâmetros não especificados",
        "saida": "Resultado de processamento",
        "libs_usadas": []
    }
    
    # Procura por imports
    imports = re.findall(r'^import\s+(\w+)|^from\s+(\w+)', conteudo_py, re.MULTILINE)
    info["libs_usadas"] = [lib[0] or lib[1] for lib in imports if (lib[0] or lib[1])]
    
    # Procura por docstrings
    docstring = re.search(r'"""(.*?)"""', conteudo_py, re.DOTALL)
    if docstring:
        info["descricao"] = docstring.group(1).strip()
    
    return info

def extrair_info_roteiro_sh(conteudo_sh):
    """Extrai informações de um roteiro.sh"""
    if not conteudo_sh:
        return []
    
    linhas = conteudo_sh.split('\n')
    passos = []
    
    for linha in linhas:
        linha = linha.strip()
        if linha and not linha.startswith('#'):
            comando = linha.split('#')[0].strip()
            if comando:
                passos.append(comando)
    
    return passos

def extrair_info_roteiro_txt(conteudo_txt):
    """Extrai informações de um roteiro.txt"""
    if not conteudo_txt:
        return []
    
    linhas = conteudo_txt.split('\n')
    passos = []
    
    for linha in linhas:
        linha = linha.strip()
        if linha:
            passos.append(linha)
    
    return passos

def gerar_readme_detalhado(pasta_path, pasta_nome):
    """Gera README detalhado para uma pasta"""
    
    readme = f"# {pasta_nome}\n\n"
    
    # Procura por roteiro.sh
    roteiro_sh = os.path.join(pasta_path, 'roteiro.sh')
    roteiro_txt = os.path.join(pasta_path, 'roteiro.txt')
    
    conteudo_roteiro_sh = None
    conteudo_roteiro_txt = None
    
    if os.path.exists(roteiro_sh):
        conteudo_roteiro_sh = ler_arquivo(roteiro_sh)
    
    if os.path.exists(roteiro_txt):
        conteudo_roteiro_txt = ler_arquivo(roteiro_txt)
    
    # Procura por arquivos Python
    scripts_python = []
    for arquivo in os.listdir(pasta_path):
        if arquivo.endswith('.py') and not arquivo.startswith('__'):
            caminho_py = os.path.join(pasta_path, arquivo)
            if os.path.isfile(caminho_py):
                conteudo_py = ler_arquivo(caminho_py)
                if conteudo_py:
                    info = extrair_info_python(conteudo_py)
                    scripts_python.append({
                        "nome": arquivo,
                        "info": info,
                        "conteudo": conteudo_py
                    })
    
    # Procura por arquivos de configuração
    configs = {
        "json": [],
        "yaml": [],
        "docx": [],
        "xlsx": []
    }
    
    for arquivo in os.listdir(pasta_path):
        if arquivo.endswith('.json'):
            configs["json"].append(arquivo)
        elif arquivo.endswith(('.yaml', '.yml')):
            configs["yaml"].append(arquivo)
        elif arquivo.endswith('.docx'):
            configs["docx"].append(arquivo)
        elif arquivo.endswith('.xlsx'):
            configs["xlsx"].append(arquivo)
    
    # DESCRIÇÃO
    readme += "## 📌 Descrição\n\n"
    readme += f"Pasta: `{pasta_nome}`\n\n"
    
    if scripts_python:
        readme += "**Scripts Python encontrados:**\n"
        for script in scripts_python:
            readme += f"- `{script['nome']}`\n"
        readme += "\n"
    
    if conteudo_roteiro_sh or conteudo_roteiro_txt:
        readme += "**Roteiro de execução disponível**\n\n"
    
    # ROTEIRO
    if conteudo_roteiro_sh:
        readme += "## 🚀 Como Executar (roteiro.sh)\n\n"
        passos = extrair_info_roteiro_sh(conteudo_roteiro_sh)
        
        if passos:
            readme += "Este script executa os seguintes passos:\n\n"
            for i, passo in enumerate(passos[:15], 1):
                readme += f"{i}. `{passo}`\n"
            
            if len(passos) > 15:
                readme += f"\n... e mais {len(passos) - 15} passos\n"
            
            readme += "\n**Como executar:**\n"
            readme += "```bash\n"
            readme += "cd /caminho/para/pasta\n"
            readme += "bash roteiro.sh\n"
            readme += "```\n\n"
        else:
            readme += "Veja o arquivo `roteiro.sh` para instruções detalhadas.\n\n"
    
    elif conteudo_roteiro_txt:
        readme += "## 📋 Roteiro de Execução\n\n"
        passos = extrair_info_roteiro_txt(conteudo_roteiro_txt)
        
        if passos:
            readme += "Passos a serem executados:\n\n"
            for i, passo in enumerate(passos[:20], 1):
                readme += f"{i}. {passo}\n"
            
            if len(passos) > 20:
                readme += f"\n... (total de {len(passos)} passos)\n"
            
            readme += "\n"
    
    # SCRIPTS PYTHON
    if scripts_python:
        readme += "## 🐍 Scripts Python\n\n"
        
        for script in scripts_python:
            readme += f"### {script['nome']}\n\n"
            readme += f"**Descrição:** {script['info']['descricao']}\n\n"
            
            if script['info']['libs_usadas']:
                libs_str = ', '.join([f'`{lib}`' for lib in script['info']['libs_usadas']])
                readme += f"**Bibliotecas usadas:** {libs_str}\n\n"
            
            readme += f"**Entrada esperada:** {script['info']['entrada']}\n\n"
            
            # Procura por exemplos de uso no código
            match_usage = re.search(r'[Uu]sage.*?["\'](.+?)["\']', script['conteudo'])
            if match_usage:
                readme += f"**Exemplo de uso:**\n"
                readme += "```bash\n"
                readme += f"python {script['nome']} {match_usage.group(1)}\n"
                readme += "```\n\n"
            else:
                readme += f"**Como usar:**\n"
                readme += "```bash\n"
                readme += f"python {script['nome']} [argumentos]\n"
                readme += "```\n\n"
        
        readme += "\n"
    
    # CONFIGURAÇÕES
    if any(configs.values()):
        readme += "## ⚙️ Arquivos de Configuração\n\n"
        
        if configs["json"]:
            readme += "**JSON:**\n"
            for arquivo in configs["json"]:
                readme += f"- `{arquivo}`\n"
            readme += "\n"
        
        if configs["yaml"]:
            readme += "**YAML:**\n"
            for arquivo in configs["yaml"]:
                readme += f"- `{arquivo}`\n"
            readme += "\n"
        
        if configs["docx"]:
            readme += "**Documentação Word:**\n"
            for arquivo in configs["docx"]:
                readme += f"- `{arquivo}`\n"
            readme += "\n"
        
        if configs["xlsx"]:
            readme += "**Planilhas Excel:**\n"
            for arquivo in configs["xlsx"]:
                readme += f"- `{arquivo}`\n"
            readme += "\n"
    
    # PRÉ-REQUISITOS
    readme += "## 📋 Pré-requisitos\n\n"
    
    if scripts_python:
        readme += "- Python 3.6+\n"
        readme += "- Bibliotecas necessárias:\n"
        todas_libs = set()
        for script in scripts_python:
            todas_libs.update(script['info']['libs_usadas'])
        
        for lib in sorted(todas_libs):
            if lib not in ['sys', 'os', 're', 'json']:
                readme += f"  - `{lib}`\n"
        
        readme += "\n**Instalar dependências:**\n"
        readme += "```bash\n"
        readme += "pip install -r requirements.txt\n"
        readme += "```\n\n"
    
    # Detecta requisitos AWS
    roteiro_combined = (conteudo_roteiro_sh or "") + (conteudo_roteiro_txt or "")
    if "saml2aws" in roteiro_combined:
        readme += "- `saml2aws` para autenticação AWS\n"
        readme += "- AWS CLI configurada\n\n"
    elif "aws" in roteiro_combined.lower():
        readme += "- AWS CLI configurada\n"
        readme += "- Credenciais AWS com permissões apropriadas\n\n"
    
    # OBSERVAÇÕES
    readme += "## ⚠️ Observações Importantes\n\n"
    readme += "- Sempre testar em ambiente DEV antes de executar em PROD\n"
    readme += "- Revisar o roteiro antes de executar automaticamente\n"
    readme += "- Fazer backup dos dados antes de operações destrutivas\n"
    readme += "- Verificar credenciais e permissões necessárias\n\n"
    
    # SUPORTE
    readme += "## 📞 Suporte\n\n"
    readme += "Para dúvidas ou problemas:\n"
    readme += "1. Verifique o arquivo `roteiro.sh` ou `roteiro.txt`\n"
    readme += "2. Consulte os comentários nos scripts Python\n"
    readme += "3. Revise os arquivos de configuração\n\n"
    
    readme += "---\n\n"
    readme += "*Documentação gerada automaticamente - Última atualização: 2026-05-26*\n"
    
    return readme

# Processar TODAS as pastas, não só as importantes
basepath = "/sessions/determined-confident-dirac/mnt/serasa"

print("Gerando READMEs detalhados com análise de conteúdo...\n")

pastas = [d for d in os.listdir(basepath) if os.path.isdir(os.path.join(basepath, d)) and not d.startswith('.')]

processadas = 0
erros = 0

for pasta_nome in sorted(pastas):
    pasta_path = os.path.join(basepath, pasta_nome)
    
    try:
        readme_content = gerar_readme_detalhado(pasta_path, pasta_nome)
        readme_path = os.path.join(pasta_path, "README.md")
        
        with open(readme_path, 'w', encoding='utf-8') as f:
            f.write(readme_content)
        
        print(f"✅ {pasta_nome}")
        processadas += 1
    except Exception as e:
        print(f"❌ {pasta_nome}: {str(e)}")
        erros += 1

print(f"\n{'='*50}")
print(f"✅ Processadas: {processadas}")
print(f"❌ Erros: {erros}")
print(f"Total: {len(pastas)}")
