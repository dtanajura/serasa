# Instalação e configuração do ambiente de observabilidade
## Servidor de Observabilidade
### Preparação do ambiente
#### 1. Conectar no servidor
Abrir o MOBATERM e conectar com ssh: 
```bash
ssh -i "observability-key.pem" ec2-user@10.99.105.48
```
#### 2. Atualizar o sistema operacional
Logar com root facilita, mas dá para rodar os comandos a seguir com sudo antes: `sudo su -`
Pode ser que seja necessário atualizar a versão do S.O., basta copiar o comando conforme sugerido após o yum update: 
```bash
dnf upgrade --releasever=2023.4.20240528
yum update -y
yum install wget tar -y
```
#### 3. Instalar o PROMETHEUS
Baixar a versão mais recente, descompactar o arquivo baixado e copiar os conteúdos para a pasta /usr/local/bin do LINUX:
```bash
wget https://github.com/prometheus/prometheus/releases/download/v2.52.0/prometheus-2.52.0.linux-amd64.tar.gz
tar xvfz prometheus-2.52.0.linux-amd64.tar.gz
cd prometheus-2.52.0.linux-amd64
cp prometheus /usr/local/bin
cp promtool /usr/local/bin
```
Criar diretórios para os arquivos de configuração e copie os seguintes diretórios para lá:
```bash
mkdir /etc/prometheus
cp -r consoles /etc/prometheus
cp -r console_libraries /etc/prometheus
cp prometheus.yml /etc/prometheus

mkdir /var/lib/prometheus
```
##### 3.1 Configurar o PROMETHEUS como um serviço do SYSTEMD
Criar um usuário para executar o PROMETHEUS: 
```bash
useradd --no-create-home --shell /bin/false prometheus
chown -R prometheus:prometheus /etc/prometheus
chown -R prometheus:prometheus /var/lib/prometheus
chown -R prometheus:prometheus /usr/local/bin/prometheus
chown -R prometheus:prometheus /usr/local/bin/promtool
```
Crie um arquivo de serviço systemd para gerenciar o Prometheus.
```bash
sudo tee /etc/systemd/system/prometheus.service <<EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
--config.file /etc/prometheus/prometheus.yml \
--storage.tsdb.path /var/lib/prometheus/ \
--web.console.templates=/etc/prometheus/consoles \
--web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF
```
##### 3.2 Iniciar e Verificar o Prometheus
Recarregar o systemd para aplicar as mudanças e inicie o serviço do Prometheus
```bash
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus
```
Verificar se o serviço está em execução.
```bash
sudo systemctl status prometheus
```
#### 3.3 Configurar o Prometheus
Editar o arquivo `/etc/prometheus/prometheus.yml` conforme suas necessidades. Por exemplo, para adicionar um target do Node Exporter:
```yaml
global:
scrape_interval: 15s

scrape_configs:
- job_name: 'node_exporter'
    static_configs:
    - targets: ['<IP_DO_SEU_SERVIDOR>:9100']
```
Reiniciar o Prometheus para Aplicar as Mudanças
```bash
sudo systemctl restart prometheus
```
#### 3.4 Acessar a Interface Web do Prometheus
A interface web do Prometheus estará disponível em `http://<IP_DO_SEU_SERVIDOR>:9090`.

### 4. Configurar acesso externo ao servidor
Alterar o security group do servidor para permitir acesso na porta 9090
```powershell
PS C:\> aws ec2 describe-instances --profile sredev --query "Reservations[].Instances[].SecurityGroups[].GroupId"
[
    "sg-08b91a735a7d4e47e"
]

PS C:\> aws ec2 describe-security-groups --filters Name=group-id,Values=sg-08b91a735a7d4e47e --profile sredev --query 'SecurityGroups[*].{GroupName:GroupName, IpPermissions:IpPermissions, IpPermissionsEgress:IpPermissionsEgress}' --output json
[
    {
        "GroupName": "secg-observability",
        "IpPermissions": [
            {
                "FromPort": 22,
                "IpProtocol": "tcp",
                "IpRanges": [
                    {
                        "CidrIp": "10.0.0.0/8",
                        "Description": "SSH"
                    }
                ],
                "Ipv6Ranges": [],
                "PrefixListIds": [],
                "ToPort": 22,
                "UserIdGroupPairs": []
            }
        ],
        "IpPermissionsEgress": [
            {
                "IpProtocol": "-1",
                "IpRanges": [
                    {
                        "CidrIp": "0.0.0.0/0"
                    }
                ],
                "Ipv6Ranges": [],
                "PrefixListIds": [],
                "UserIdGroupPairs": []
            }
        ]
    }
]

PS C:\> aws ec2 authorize-security-group-ingress --group-id sg-08b91a735a7d4e47e --protocol tcp --port 9090 --cidr 10.0.0.0/8 --profile sredev
```
### 5. Instalar o Grafana
#### 5.1 Adicionar o Repositório e instalar o Grafana
Criar um arquivo de repositório para o Grafana
```bash
sudo tee /etc/yum.repos.d/grafana.repo <<EOF
[grafana]
name=grafana
baseurl=https://packages.grafana.com/oss/rpm
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://packages.grafana.com/gpg.key
EOF

sudo yum install grafana -y
```
#### 5.2 Iniciar e Habilitar o Serviço do Grafana
Iniciar e habilitar o serviço do Grafana.
```bash
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
sudo systemctl status grafana-server
```

Certifique-se de adicionar uma regra para permitir o tráfego na porta 3000.

#### 5.3 Configurar o Grafana
No navegador, acessar o Grafana em `http://<IP_DO_SEU_SERVIDOR>:3000`.
Fazer login com as credenciais padrão:
- Usuário: `admin`
- Senha: `admin`

- Após o login, você será solicitado a alterar a senha padrão.

Adicionar o Data Source do Prometheus**
- Vá para **Configuration** (ícone de engrenagem) > **Data Sources**.
- Clique em **Add data source**.
- Selecione **Prometheus**.
- Configure o data source com a URL do Prometheus, por exemplo, `http://10.99.105.48:9090`.
- Clique em **Save & Test** para garantir que o Grafana pode se conectar ao Prometheus.

### 5.4 Criar um Dashboard
Criar um Novo Dashboard
- Vá para **Create** (ícone de "+" na barra lateral) > **Dashboard**.
- Clique em **Add new panel**.
- No painel de configuração, configure as métricas que você deseja visualizar a partir do Prometheus.
- Por exemplo, para visualizar a utilização da CPU:
    - Em **Query**, selecione `Prometheus` como a fonte de dados.
    - Insira a seguinte consulta Prometheus:
       ```prometheus
       rate(node_cpu_seconds_total[1m])
       ```
Salvar o Dashboard
- Depois de configurar os painéis conforme necessário, clique em **Apply** para salvar as alterações.
- Dê um nome ao seu dashboard e salve-o.

