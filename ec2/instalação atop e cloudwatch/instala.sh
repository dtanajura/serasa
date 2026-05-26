#    Install the EPEL release package for RHEL 8:
sudo dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm -y
#    Install the monitoring tools:
sudo dnf -y install sysstat atop --enablerepo=epel
#    Change the log collection interval:
sudo sed -i 's/^LOGINTERVAL=600.*/LOGINTERVAL=60/' /etc/sysconfig/atop
sudo mkdir -v /etc/systemd/system/sysstat-collect.timer.d/
sudo bash -c "sed -e 's|every 10 minutes|every 1 minute|g' -e '/^OnCalendar=/ s|/10$|/1|' /usr/lib/systemd/system/sysstat-collect.timer > /etc/systemd/system/sysstat-collect.timer.d/override.conf"
sudo sed -i 's|^SADC_OPTIONS=.*|SADC_OPTIONS=" -S XALL"|' /etc/sysconfig/sysstat
#    Enable and restart services:
sudo systemctl enable atop.service crond.service sysstat.service
sudo systemctl restart atop.service crond.service sysstat.service
#   Change Zabbix Server
sudo sed -i 's/^Server=10.99.188.197.*/Server=10.99.188.197,10.99.133.123/' /etc/zabbix/zabbix_agent2.conf
sudo sed -i 's/^ServerActive=10.99.188.197.*/ServerActive=10.99.188.197,10.99.133.123/' /etc/zabbix/zabbix_agent2.conf
sudo systemctl restart zabbix-agent2.service

sudo systemctl status crond.service 
sudo systemctl status atop.service 
# sudo systemctl status sysstat.service
sudo cat /etc/zabbix/zabbix_agent2.conf | grep Server
sudo systemctl status zabbix-agent2.service

# Download do agente CloudWatch
sudo wget https://s3.sa-east-1.amazonaws.com/amazoncloudwatch-agent-sa-east-1/redhat/amd64/latest/amazon-cloudwatch-agent.rpm
# Instalar o package
sudo rpm -U ./amazon-cloudwatch-agent.rpm
# Verificar o serviço
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a status

# Para cada servidor:
sudo cp /etc/sysctl.conf /etc/sysctl.conf.old
sudo tee -a /etc/sysctl.conf &>/dev/null <<EOF
kernel.panic_on_io_nmi = 1
kernel.panic_on_unrecovered_nmi = 1
kernel.unknown_nmi_panic = 1
EOF

sudo sed -i 's/^kernel.sysrq=0.*/kernel.sysrq=1/' /etc/sysctl.conf
sudo cat /etc/sysctl.conf

sudo tee /etc/hostname &>/dev/null <<EOF
ip-10-99-133-144.ec2.internal
EOF

#Lista de IPs
IP	Instance	Name
10.99.133.35	i-050c8499bde7754e7	mongodb-account-iam-a
10.99.133.111	i-07ae20fdcdec6ee5a	mongodb-account-iam-b
10.99.133.161	i-09e4589367dea52d9	mongodb-account-iam-c
10.99.133.26	i-0625c591926220106	mongodb-digital-commerce-services-a
10.99.133.84	i-0758139453749b37c	mongodb-digital-commerce-services-b
10.99.133.163	i-08d2476f8df840f86	mongodb-digital-commerce-services-c
10.99.133.19	i-07258cf005f4b6f7c	mongodb-digital-kyc-services-a
10.99.133.119	i-040589b63ec887bc3	mongodb-digital-kyc-services-b
10.99.133.165	i-0f7ca31d245157283	mongodb-digital-kyc-services-c
10.99.133.10	i-00fb3909f2dc67e75	mongodb-digital-security-services-a
10.99.133.106	i-0ae59012b850092ea	mongodb-digital-security-services-b
10.99.133.147	i-056a9fdd429bc8597	mongodb-digital-security-services-c
10.99.133.11	i-09f265a616039aca0	mongodb-digital-services-a
10.99.133.93	i-02eda1ee5d9dbf723	mongodb-digital-services-b
10.99.133.144	i-0d8633613afda78ef	mongodb-digital-services-c
10.99.133.47	i-0a086eb593d178176	mongodb-digital-uat-a
10.99.133.91	i-033b9946cb711499b	mongodb-digital-uat-b
10.99.133.174	i-0a6c284bc46b400a2	mongodb-digital-uat-c
