# Ferramentas de Apoio para Kafka Partition Reassignment

Este repositório contém arquivos auxiliares utilizados durante **operações de reassignment de partitions em clusters Kafka**, com foco em **organização, verificação de status e conversão de saídas textuais** para formatos estruturados.

Os arquivos aqui descritos são voltados para **uso operacional**, principalmente em cenários de manutenção, rebalanceamento ou expansão de brokers.

---

## Objetivo

- Apoiar processos de reassignment de partitions no Kafka
- Converter saídas textuais em JSON estruturado
- Facilitar o acompanhamento do progresso das operações
- Servir como evidência e referência operacional versionada

---

## Arquivos

### `converter.py`

Script em Python responsável por **converter a saída textual de um reassignment** em um arquivo JSON estruturado.

Funções principais:
- Ler um arquivo de entrada contendo informações de partitions
- Extrair:
  - Tópico
  - Partition
  - Réplicas
  - Diretórios de log
- Gerar um arquivo `reassignment_clean.json` no formato esperado pelo Kafka

Uso típico:
- Preparar arquivos de reassignment
- Normalizar saídas brutas para reutilização
- Apoiar ajustes ou reexecuções de reassignments

---

### `verify.txt`

Arquivo contendo o **resultado da verificação do reassignment de partitions**, normalmente gerado a partir de comandos Kafka de verificação.

Características:
- Lista detalhada por tópico e partition
- Status apresentados:
  - `is complete`
  - `is still in progress`
- Pode conter centenas ou milhares de linhas
- Serve como:
  - Evidência operacional
  - Base para análise de progresso
  - Insumo para troubleshooting

Formato típico das linhas:
```
Reassignment of partition <topic>-<partition> is <status>
```

---

## Fluxo de Uso Recomendo

1. Executar o reassignment de partitions no Kafka
2. Executar a verificação do reassignment
3. Salvar a saída da verificação em um arquivo (`verify.txt`)
4. Analisar o progresso identificando partitions:
   - Finalizadas (`complete`)
   - Ainda em execução (`still in progress`)
5. Utilizar o `converter.py` quando houver necessidade de gerar ou ajustar JSONs de reassignment

---

## Boas Práticas

- Sempre versionar arquivos de entrada e saída usados na operação
- Evitar interromper reassignments ainda em andamento
- Executar reassignments fora de janelas críticas sempre que possível
- Monitorar impacto em produtores e consumidores
- Tratar estes scripts como **apoio operacional**, não automação indiscriminada

---

## Avisos Importantes

⚠️ Reassignments de Kafka impactam performance e latência  
⚠️ Alterações devem ser feitas de forma planejada  
⚠️ O uso indevido pode gerar rebalanceamentos prolongados  

---

## Público-alvo

- SRE
- DevOps
- Platform Engineers
- Times responsáveis por Kafka / MSK
- Operações de dados e streaming

---

## Observação Final

Este repositório tem caráter **operacional e de suporte**, servindo para facilitar a leitura, organização e reaproveitamento de informações durante processos de reassignment de partitions em larga escala.

Sempre revise os arquivos antes de utilizá-los em ambientes produtivos.
