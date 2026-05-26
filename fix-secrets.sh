#!/bin/bash

echo "🚨 Removendo arquivos com secrets..."

# Arquivos que o GitHub apontou
FILES=(
"s3/Migração dos buckets/roteiro migração bucket.sh"
"ec2/Instalação Prometheus/assume-role/roteiro.sh"
)

# 1. Remover do git (index)
for file in "${FILES[@]}"; do
  git rm --cached "$file" 2>/dev/null
done

# 2. Remover fisicamente
for file in "${FILES[@]}"; do
  rm -f "$file"
done

# 3. Adicionar ao .gitignore
echo "🚫 Bloqueando arquivos no .gitignore..."
for file in "${FILES[@]}"; do
  echo "$file" >> .gitignore
done

git add .gitignore

# 4. RESETAR commit (ESSENCIAL)
echo "⏪ Resetando commits para limpar histórico recente..."
git reset --soft origin/main

# 5. Recriar commit limpo
echo "✅ Criando commit sem secrets..."
git add .
git commit -m "cleanup: remove AWS secrets"

echo "🚀 Pronto para push!"
``
