# 🖥️ Roteiro – Instalação Atop + Sysstat + CloudWatch Agent

## 🎯 Objetivo

Provisionar ferramentas de monitoramento em EC2 para:

* ✅ Monitoramento de recursos (CPU, MEM, IO)
* ✅ Histórico detalhado (atop + sysstat)
* ✅ Integração com CloudWatch
* ✅ Suporte a troubleshooting

***

# 📋 1. Pré-requisitos

* EC2 Linux (RHEL/CentOS/Alma/Amazon Linux)
* Acesso sudo/root
* Role IAM com acesso ao CloudWatch

***

# 📦 2. Instalar dependências (EPEL + ferramentas)

## ▶️ Instalar EPEL

```bash
sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
```

***

## ▶️ Instalar atop + sysstat

```bash
sudo dnf install -y sysstat atop --enablerepo=epel
```

👉 Instala ferramentas principais de monitoring [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/instala.sh)

***

# ⚙️ 3. Configurar coleta de métricas

## 🔁 Alterar frequência do ATOP

```bash
sudo sed -i 's/^LOGINTERVAL=.*/LOGINTERVAL=60/' /etc/sysconfig/atop
```

👉 Coleta a cada 60 segundos    [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/instala.sh)

***

## 🔁 Ajustar SYSSTAT para 1 minuto

```bash
sudo mkdir -p /etc/systemd/system/sysstat-collect.timer.d/

sudo bash -c 'cat > /etc/systemd/system/sysstat-collect.timer.d/override.conf <<EOF
[Timer]
OnCalendar=*:0/1
EOF'
```

***

## 🔧 Ativar métricas completas

```bash
sudo sed -i 's/^SADC_OPTIONS=.*/SADC_OPTIONS="-S XALL"/' /etc/sysconfig/sysstat
```

👉 Habilita coleta completa    [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/instala.sh)

***

# ▶️ 4. Ativar serviços

```bash
sudo systemctl enable atop.service
sudo systemctl enable sysstat.service
sudo systemctl enable crond.service

sudo systemctl restart atop.service sysstat.service crond.service
```

***

## 🔎 Validar

```bash
sudo systemctl status atop.service
sudo systemctl status sysstat.service
```

***

# 📊 5. Verificar coleta

## Atop

```bash
atop
```

***

## Histórico

```bash
atop -r /var/log/atop/atop_*
```

***

## Sysstat

```bash
sar -u 1 5
```

***

# ☁️ 6. Instalar CloudWatch Agent

## ▶️ Download

```bash
sudo wget https://s3.sa-east-1.amazonaws.com/amazoncloudwatch-agent-sa-east-1/redhat/amd64/latest/amazon-cloudwatch-agent.rpm
```

## ▶️ Instalar

```bash
sudo rpm -U amazon-cloudwatch-agent.rpm
```

👉 Instalando agente oficial AWS    [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/instala.sh)

***

# 🔐 7. Validar CloudWatch Agent

```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a status
```

***

# ⚙️ 8. Configuração adicional (sysctl)

## 🔐 Habilitar NMI panic (monitoramento crítico)

```bash
sudo tee -a /etc/sysctl.conf <<EOF
kernel.panic_on_io_nmi = 1
kernel.panic_on_unrecovered_nmi = 1
kernel.unknown_nmi_panic = 1
EOF
```

***

## 🔧 Habilitar sysrq

```bash
sudo sed -i 's/^kernel.sysrq=0.*/kernel.sysrq=1/' /etc/sysctl.conf
```

 [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/instala.sh)

***

# 🌐 9. Ajuste de hostname (opcional)

```bash
sudo tee /etc/hostname <<EOF
ip-xx-xx-xx-xx.ec2.internal
EOF
```

***

# 🔧 10. Integração com Zabbix (opcional)

```bash
sudo sed -i 's/^Server=.*/Server=10.99.188.197,10.99.133.123/' /etc/zabbix/zabbix_agent2.conf
sudo sed -i 's/^ServerActive=.*/ServerActive=10.99.188.197,10.99.133.123/' /etc/zabbix/zabbix_agent2.conf

sudo systemctl restart zabbix-agent2
```

 [\[experian-m...epoint.com\]](https://experian-my.sharepoint.com/personal/davi_tanajura_br_experian_com/Documents/Microsoft%20Copilot%20Chat%20Files/instala.sh)

***

# ✅ 11. Checklist final

* ✅ atop instalado e coletando
* ✅ sysstat ativo
* ✅ CloudWatch agent instalado
* ✅ Logs sendo enviados
* ✅ serviços habilitados
* ✅ frequência ajustada (1 min)

***

# ⚠️ Pontos de atenção

## 📊 Performance

* Intervalo menor = mais dados, mais uso de disco
* Atop gera logs grandes

***

## ☁️ CloudWatch

* Verificar IAM Role:

```json
CloudWatchAgentServerPolicy
```

***

## 💾 Logs

```bash
/var/log/atop/
/var/log/sa/
```

***

# 🚀 Boas práticas

* ✅ Centralizar logs no CloudWatch
* ✅ Usar atop para troubleshooting (CPU spikes)
* ✅ Usar sysstat para histórico
* ✅ Automatizar via script/SSM
* ✅ Rotacionar logs

***

# 🔥 Script consolidado (melhorado)

```bash
#!/bin/bash

echo "Instalando ferramentas..."

sudo dnf install -y epel-release
sudo dnf install -y sysstat atop

echo "Configurando coleta..."

sudo sed -i 's/^LOGINTERVAL=.*/LOGINTERVAL=60/' /etc/sysconfig/atop
sudo sed -i 's/^SADC_OPTIONS=.*/SADC_OPTIONS="-S XALL"/' /etc/sysconfig/sysstat

echo "Habilitando serviços..."

sudo systemctl enable atop sysstat crond
sudo systemctl restart atop sysstat crond

echo "Instalando CloudWatch Agent..."

wget https://s3.sa-east-1.amazonaws.com/amazoncloudwatch-agent-sa-east-1/redhat/amd64/latest/amazon-cloudwatch-agent.rpm
sudo rpm -U amazon-cloudwatch-agent.rpm

echo "Finalizado ✅"
```

***

# 🧠 Próximo nível (posso montar)

* 🔹 configuração completa CloudWatch (cpu/mem/disk)
* 🔹 dashboard Grafana
* 🔹 integração com Prometheus
* 🔹 coleta via FluentBit
* 🔹 automação via SSM

***

✅ Resumo direto:

Você está montando um stack:

* atop → troubleshooting detalhado
* sysstat → histórico
* CloudWatch → observabilidade central

👉 Isso já é padrão **SRE completo de monitoring de EC2**
