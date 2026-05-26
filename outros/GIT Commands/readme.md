# 🧪 Roteiro – Comandos Git (Base SRE / DevOps)

## 🎯 Objetivo

Padronizar o uso do Git para:

* Controle de código
* Versionamento de scripts/infra
* Fluxo de desenvolvimento (branches)
* Integração com pipelines

***

# 📦 1. Configuração inicial

```bash
git config --global user.name "Seu Nome"
git config --global user.email "seu@email.com"
```

***

## 🔍 Ver configuração

```bash
git config --list
```

***

# 📂 2. Inicialização de repositório

## Criar repo local

```bash
git init
```

***

## Clonar repositório

```bash
git clone https://github.com/org/repo.git
```

***

# 📋 3. Status e tracking

## Ver status

```bash
git status
```

***

## Ver diff

```bash
git diff
```

***

## Ver histórico

```bash
git log --oneline
```

***

# ➕ 4. Adicionar arquivos

## Adicionar arquivo específico

```bash
git add arquivo.txt
```

***

## Adicionar tudo

```bash
git add .
```

***

# 💾 5. Commit

```bash
git commit -m "Descrição da alteração"
```

***

## Commit com add direto

```bash
git commit -am "fix: ajuste script"
```

***

# 🔀 6. Branches

## Criar branch

```bash
git checkout -b feature/novo-script
```

***

## Listar branches

```bash
git branch
```

***

## Trocar branch

```bash
git checkout main
```

***

## Deletar branch

```bash
git branch -d feature/branch
```

***

# 🔄 7. Sincronização com remoto

## Conectar remoto

```bash
git remote add origin https://github.com/org/repo.git
```

***

## Ver remotos

```bash
git remote -v
```

***

## Push inicial

```bash
git push -u origin main
```

***

## Push normal

```bash
git push
```

***

## Pull (atualizar local)

```bash
git pull
```

***

## Fetch (sem merge)

```bash
git fetch
```

***

# 🔃 8. Merge e Rebase

## Merge

```bash
git merge main
```

***

## Rebase

```bash
git rebase main
```

***

## Resolver conflito

```bash
git status
# editar arquivos
git add .
git commit
```

***

# 🧹 9. Limpeza e desfazer mudanças

## Reset soft

```bash
git reset --soft HEAD~1
```

***

## Reset hard (⚠️ risco)

```bash
git reset --hard HEAD~1
```

***

## Descartar alterações

```bash
git checkout -- arquivo.txt
```

***

# 🔙 10. Reverter commit

```bash
git revert <commit-id>
```

***

# 🧠 11. Stash (guardar mudanças temporárias)

```bash
git stash
```

***

## Recuperar

```bash
git stash pop
```

***

# 🔍 12. Tags

## Criar tag

```bash
git tag v1.0.0
```

***

## Push tag

```bash
git push origin v1.0.0
```

***

# 🚀 13. Fluxo padrão da squad (recomendado)

## 💡 Workflow sugerido

```text
main
 └── develop
      ├── feature/*
      ├── bugfix/*
      └── hotfix/*
```

***

### Passo a passo:

```bash
git checkout -b feature/meu-script
# codar
git add .
git commit -m "feat: novo script firehose"
git push origin feature/meu-script
```

***

# 🔐 14. Boas práticas

* ✅ Commits pequenos e descritivos
* ✅ Nome padrão:

```text
feat:
fix:
chore:
refactor:
```

* ✅ Nunca commitar:
  * secrets
  * credenciais

***

# ⚠️ 15. Erros comuns

## ❌ Force push perigoso

```bash
git push --force
```

👉 Usar apenas com cuidado

***

## ❌ Merge direto na main

👉 Sempre via PR

***

# 🔥 16. Script útil (setup rápido)

```bash
#!/bin/bash

git init
git add .
git commit -m "Initial commit"

git remote add origin $1
git branch -M main
git push -u origin main

```

# ✅ 17. Checklist rápido

* ✅ Repo configurado
* ✅ Branch correta
* ✅ Commit descritivo
* ✅ Push realizado
* ✅ PR aberto

***
