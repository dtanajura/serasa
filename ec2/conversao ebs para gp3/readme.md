# 💾 Roteiro – Conversão de Volumes EBS (GP2 → GP3)

## 🎯 Objetivo

Migrar volumes EBS do tipo **gp2 para gp3**, garantindo:

* Redução de custo 💰
* Preservação de performance ⚡
* Zero downtime ✅
* Validação pós-migração 🔍

***

# 🧠 1. Conceito da migração

### 🔄 Diferença principal

| Tipo | Performance                    | Custo       |
| ---- | ------------------------------ | ----------- |
| gp2  | baseado em tamanho             | mais caro   |
| gp3  | IOPS + throughput configurável | mais barato |

***

### ⚙️ Estratégia do script

Seu script:

* Detecta volumes gp2 automaticamente
* Calcula performance equivalente
* Aplica:
  * IOPS
  * Throughput

📌 Regra:

```text
IOPS = min(16000, 3 * tamanho)
mínimo GP3 = 3000 IOPS
Throughput:
- >= 334 GiB → 250 MiB/s
- < 334 GiB → 125 MiB/s
```

 [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/migrar_gp2_para_gp3.py)

***

# 🔍 2. Identificar volumes gp2

## ▶️ Execução

```bash
python3 migrar_gp2_para_gp3.py \
  --profile dataofficedev \
  --wait \
  --no-preserve-perf
```

***

## 📊 Exemplo de saída

```text
Volumes GP2 encontrados:

vol-07f9... 15 GiB in-use
vol-0722... 50 GiB in-use
```

 [\[discos_migrados \| Txt\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/discos_migrados.txt)

***

# 🔐 3. (Opcional) Criar snapshot antes

✅ Recomendado para produção:

```bash
--snapshot-before
```

👉 Garante rollback

***

# 🧪 4. Dry-run (simular sem alterar)

```bash
python3 migrar_gp2_para_gp3.py \
  --profile dataofficedev \
  --dry-run
```

👉 Apenas mostra o que será feito

***

# 🚀 5. Executar migração

## ▶️ Comando padrão

```bash
python3 migrar_gp2_para_gp3.py \
  --profile dataofficedev \
  --wait \
  --snapshot-before
```

***

## ✅ O que acontece:

* Identifica volumes gp2
* (Opcional) cria snapshot
* Executa:

```bash
modify-volume → gp3
```

* Aguarda conclusão

***

## 📌 Sem downtime

👉 Volume pode estar **in-use** durante mudança  
👉 AWS aplica alteração online

***

# 🔄 6. Acompanhar progresso

O script usa:

```bash
describe_volumes_modifications
```

👉 Status:

* `modifying`
* `optimizing`
* `completed`

 [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/migrar_gp2_para_gp3.py)

***

# ✅ 7. Verificação pós-migração

## ▶️ Rodar script de validação

```bash
python3 verificar_migracao_gp3.py \
  --profile dataofficedev \
  --region sa-east-1 \
  --only-gp2 \
  --fail-if-gp2
```

***

## 🔎 O que ele valida:

* Tipo do volume
* Estado (in-use / available)
* Se ainda existe gp2
* Progresso de modificação

 [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/verificar_migracao_gp3.py)

***

## ✅ Resultado esperado

```text
Nenhum volume gp2 encontrado ✅
```

***

# 📊 8. Resultado real (do seu ambiente)

Você já executou em várias contas:

* dataofficedev ✅
* datahubdev ✅
* nikedataservicedev ✅
* ssrmdev ✅

👉 Alguns ambientes já 100% migrados:

```
Nenhum volume GP2 encontrado
```

👉 Outros tinham dezenas de volumes    [\[discos_migrados \| Txt\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/discos_migrados.txt)

***

## 💰 Economia estimada

```text
Mensal: ~$86,41
Anual: ~$1.036,92
```

 [\[discos_migrados \| Txt\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/discos_migrados.txt)

***

# ⚠️ 9. Pontos de atenção

* Não reduzir IOPS abaixo do necessário
* Workloads críticos:
  * validar antes
* Snapshots aumentam custo temporário
* Performance pode mudar se usar:

```bash
--no-preserve-perf
```

***

# 🚀 10. Boas práticas

* ✅ Sempre rodar dry-run
* ✅ Criar snapshot em produção
* ✅ Executar por ambiente (dev → prod)
* ✅ Monitorar CloudWatch após mudança
* ✅ Validar aplicações

***

# 🔥 11. Script padrão consolidado

```bash
#!/bin/bash

PROFILE=$1

echo "🔍 Verificando volumes gp2..."

python3 migrar_gp2_para_gp3.py \
  --profile $PROFILE \
  --dry-run

echo "🚀 Executando migração..."

python3 migrar_gp2_para_gp3.py \
  --profile $PROFILE \
  --wait \
  --snapshot-before

echo "✅ Validando..."

python3 verificar_migracao_gp3.py \
  --profile $PROFILE \
  --only-gp2 \
  --fail-if-gp2

echo "Concluído ✅"
```

***

# 🧠 Próximo nível (posso montar pra você)

* 🔹 Lambda automático de migração
* 🔹 auditoria contínua (gp2 → alerta)
* 🔹 dashboard FinOps (EBS savings)
* 🔹 automação via SSM em todas contas
* 🔹 política AWS Config para bloquear gp2

