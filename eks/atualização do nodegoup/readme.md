# Procedimentos de Atualização e Escalonamento de Nodegroups EKS

Este repositório contém scripts operacionais utilizados para **verificação, administração e ajuste de capacidade (scale up / scale down) de nodegroups em clusters Amazon EKS**.

O objetivo é padronizar e documentar procedimentos recorrentes de operação em múltiplos ambientes AWS.

---

## Objetivo

- Ajustar capacidade de nodegroups EKS (min / max / desired)
- Verificar Auto Scaling Groups associados aos nodegroups
- Apoiar ações operacionais controladas em ambientes EKS
- Manter histórico versionado de procedimentos executados

---

## Arquivos do Repositório

- **`roteiro.sh`**
  - Roteiro operacional para inspeção de clusters e nodegroups
  - Consulta de ASGs e instâncias associadas
  - Atualizações pontuais de configuração
  - Validação de nós via `kubectl`

- **`sobe-nodes.sh`**
  - Comandos direcionados para ajuste de capacidade de nodegroups
  - Abrange múltiplos ambientes, contas e clusters
  - Foco em scale up e scale down controlado

---

## Pré-requisitos

Antes de executar qualquer procedimento, é necessário:

- AWS CLI instalada e configurada
- Perfis AWS corretamente configurados
- Permissões IAM para EKS e Auto Scaling
- `kubectl` instalado
- Contexto do cluster EKS configurado quando aplicável

---

## Uso Geral

1. Identificar o ambiente, cluster e nodegroup a ser ajustado
2. Revisar cuidadosamente os parâmetros de escalabilidade
3. Executar os comandos de forma manual e controlada
4. Validar o estado dos nós após a alteração
5. Registrar quaisquer ajustes relevantes no repositório

---

## Boas Práticas

- Executar comandos **um por vez**
- Evitar execução automática ou em lote
- Revisar impacto antes de alterações em produção
- Não reduzir nodegroups críticos sem validação
- Confirmar estado do cluster após cada ajuste
- Manter este repositório sempre atualizado

---

## Avisos Importantes

⚠️ Este repositório contém **procedimentos operacionais**  
⚠️ Uso indevido pode causar indisponibilidade ou impacto em workloads  
⚠️ Alterações em produção devem seguir processos de aprovação internos  

---

## Público-alvo

- SRE
- DevOps
- Platform Engineers
- Times responsáveis por operação de clusters EKS

---

## Observação Final

Os scripts aqui presentes servem como **referência prática** e **apoio à operação**, não como automação padrão.  
Sempre adapte os procedimentos conforme o ambiente e as políticas vigentes.

---