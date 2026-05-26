# 📊 Roteiro – Atualização do Zabbix Agent 2 (RHEL/CentOS 8)

## 🎯 Objetivo

Atualizar o Zabbix Agent 2 para versão mais recente, incluindo:

* Atualização do repositório
* Upgrade do agente
* Atualização/limpeza de plugins
* Validação do serviço

***

## 📋 Pré-requisitos

* Acesso root/sudo
* Conectividade com repositório Zabbix
* Ambiente RHEL/CentOS 8
* Backup de configuração (recomendado)

***

# 🔄 1. Download de pacotes

```bash
sudo wget https://repo.zabbix.com/zabbix/6.4/rhel/8/x86_64/zabbix-release-6.4-1.el8.noarch.rpm
sudo wget https://repo.zabbix.com/zabbix/6.4/rhel/8/x86_64/zabbix-agent2-plugin-mongodb-6.4.3-release1.el8.x86_64.rpm
```

 [\[atualiza \| Txt\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/atualiza.txt)

***

# 📦 2. Atualizar repositório Zabbix

```bash
sudo rpm -Uvh zabbix-release-6.4-1.el8.noarch.rpm
```

 [\[atualiza \| Txt\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/atualiza.txt)

***

# ⛔ 3. Parar o serviço

```bash
sudo systemctl stop zabbix-agent2
```

 [\[atualiza \| Txt\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/atualiza.txt)

***

# ⬆️ 4. Atualizar o agente

```bash
sudo yum update zabbix-agent2 -y
```

 [\[atualiza \| Txt\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/atualiza.txt)

***

# 🔌 5. Instalar plugins atualizados

```bash
sudo yum localinstall zabbix-agent2-plugin-mongodb-6.4.3-release1.el8.x86_64.rpm -y
```

 [\[atualiza \| Txt\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/atualiza.txt)

***

# 🧹 6. Remover plugins antigos

## Remover todos os plugins antigos (opcional geral)

```bash
sudo yum remove zabbix-agent2-plugin-* -y
```

***

## Remover versões específicas antigas

```bash
sudo yum remove zabbix-agent2-plugin-mongodb-6.0.18-release1.el8.x86_64 -y
sudo yum remove zabbix-agent2-plugin-postgresql-6.0.18-release1.el8.x86_64 -y
```

 [\[atualiza \| Txt\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/atualiza.txt)

***

# 🔍 7. Validar pacotes instalados

```bash
rpm -qa | grep zabbix
```

 [\[atualiza \| Txt\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/atualiza.txt)

***

# ▶️ 8. Subir serviço

```bash
sudo systemctl restart zabbix-agent2
```

***

# ✅ 9. Validar status

```bash
sudo systemctl status zabbix-agent2
```

✅ Esperado:

* `active (running)`

 [\[atualiza \| Txt\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/atualiza.txt)

***

# 🔎 10. Validação funcional (recomendado)

## Teste local

```bash
zabbix_agent2 -t system.cpu.load
```

## Teste via server

```bash
zabbix_get -s <IP_HOST> -k system.uptime
```

***

# ⚠️ Pontos de atenção

* Atualização remove plugins incompatíveis
* Verificar:
  * `/etc/zabbix/zabbix_agent2.conf`
* Plugins precisam ser compatíveis com versão 6.4
* Se estiver em VPC restrita:
  * validar acesso ao repositório

***

# 🚀 Boas práticas

* ✅ Fazer backup antes:

```bash
cp /etc/zabbix/zabbix_agent2.conf /tmp/
```

* ✅ Validar conectividade com Zabbix Server
* ✅ Monitorar logs:

```bash
tail -f /var/log/zabbix/zabbix_agent2.log
```

* ✅ Atualizar em janela controlada

***

# 🔥 Script automatizado (opcional)

```bash
#!/bin/bash

echo "Atualizando Zabbix Agent..."

sudo systemctl stop zabbix-agent2

sudo rpm -Uvh zabbix-release-6.4-1.el8.noarch.rpm
sudo yum update zabbix-agent2 -y

sudo yum remove zabbix-agent2-plugin-* -y
sudo yum localinstall zabbix-agent2-plugin-mongodb-6.4.3-release1.el8.x86_64.rpm -y

sudo systemctl restart zabbix-agent2

echo "Status final:"
sudo systemctl status zabbix-agent2
```

***

# ✅ Conclusão

Esse processo garante:

* Atualização segura do agente
* Compatibilidade com plugins
* Ambiente limpo (sem versões antigas)
* Monitoramento contínuo funcional

