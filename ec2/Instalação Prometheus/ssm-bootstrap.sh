#!/bin/bash
## Name: SSM Agent Installer Script
## Description: Installs SSM Agent on EMR cluster EC2 instances and update hosts file
##
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo systemctl status amazon-ssm-agent >>/tmp/ssm-status.log
## Update hosts file
echo "\n ########### localhost mapping check ########### \n" > /tmp/localhost.log
lhost=`sudo cat /etc/hosts | grep localhost | grep '127.0.0.1' | grep -v '^#'`
v_ipaddr=`hostname --ip-address`
lhostmapping=`sudo cat /etc/hosts | grep $v_ipaddr | grep -v '^#'`
if [ -z "${lhostmapping}" ];
then
echo "\n ########### IP address to localhost mapping NOT defined in hosts files. add now ########### \n " >> /tmp/localhost.log
sudo echo "${v_ipaddr} localhost" >>/etc/hosts
else
echo "\n IP address to localhost mapping already defined in hosts file \n" >> /tmp/localhost.log
fi
echo "\n ########### IP Address to localhost mapping check complete and below is the content ########### " >> /tmp/localhost.log
sudo cat /etc/hosts >> /tmp/localhost.log


# Instalação do node exporter
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

echo "\n ########### Exit script ########### " >> /tmp/localhost.log
