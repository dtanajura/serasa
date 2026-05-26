#!/bin/bash
sudo yum update -y
arch=$(uname -m)
cd ~

# Baixar e instalar o JMX Exporter
if [ $arch == "aarch64" ]
then
    wget https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.16.1/jmx_prometheus_javaagent-0.16.1.jar
elif [ $arch == "x86_64" ]
then
    wget https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.16.1/jmx_prometheus_javaagent-0.16.1.jar
else
    echo "Outra plataforma: $arch"
fi

# Criar diretório para o JMX Exporter
sudo mkdir -p /opt/jmx_exporter
sudo mv jmx_prometheus_javaagent-0.16.1.jar /opt/jmx_exporter/

# Criar arquivo de configuração do JMX Exporter
sudo tee /opt/jmx_exporter/config.yaml <<EOF
---
startDelaySeconds: 0
hostPort: 0.0.0.0:12345
ssl: false
lowercaseOutputName: false
lowercaseOutputLabelNames: false
whitelistObjectNames: ["java.lang:type=Memory", "java.lang:type=GarbageCollector,*"]
EOF

# Criar usuário para o JMX Exporter
sudo useradd --no-create-home --shell /bin/false jmxusr
sudo chown -R jmxusr:jmxusr /opt/jmx_exporter

# Criar serviço systemd para o JMX Exporter
sudo tee /etc/systemd/system/jmx_exporter.service <<EOF
[Unit]
Description=JMX Exporter
After=network.target

[Service]
User=jmxusr
ExecStart=/usr/bin/java -javaagent:/opt/jmx_exporter/jmx_prometheus_javaagent-0.16.1.jar=12345:/opt/jmx_exporter/config.yaml

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start jmx_exporter
sudo systemctl enable jmx_exporter
