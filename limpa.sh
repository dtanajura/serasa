#!/bin/bash

echo "🔎 Procurando arquivos sensíveis..."

# 1. Remover arquivos comuns de segredo
find . -type f \( \
    -iname "*secret*" -o \
    -iname "*key*" -o \
    -iname "*token*" -o \
    -iname "*password*" \
\) -print -exec rm -f {} \;

# 2. Remover arquivos do macOS
find . -name ".DS_Store" -type f -delete

# 3. Remover diretórios conhecidos problemáticos
rm -rf "Onboarding contas devexperience"

# 4. Remover .git internos (subrepos)
find . -type d -name ".git" ! -path "./.git" -exec rm -rf {} +

echo "✅ Limpeza concluída!"

