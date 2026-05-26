#!/bin/bash
sudo yum update -y
arch=$(uname -m)
cd ~

if [ $arch == "aarch64" ]
then
    wget https://github.com/prometheus/node_exporter/releases/download/v1.8.1/node_exporter-1.8.1.linux-arm64.tar.gz
    tar xvfz node_exporter-1.8.1.linux-arm64.tar.gz
    sudo cp node_exporter-1.8.1.linux-arm64/node_exporter /usr/local/bin/
elif [ $arch == "x86_64" ]
then
    wget https://github.com/prometheus/node_exporter/releases/download/v1.8.1/node_exporter-1.8.1.linux-amd64.tar.gz
    tar xvfz node_exporter-1.8.1.linux-amd64.tar.gz
    sudo cp node_exporter-1.8.1.linux-amd64/node_exporter /usr/local/bin/
else
    echo "Outra plataforma: $arch"
fi
sudo useradd --no-create-home --shell /bin/false nodeusr
sudo chown nodeusr:nodeusr /usr/local/bin/node_exporter

sudo tee /etc/systemd/system/node_exporter.service <<EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=nodeusr
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
