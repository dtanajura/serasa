### Passo 1: Preparar o Ambiente

1. **Atualizar o Sistema**
   - Atualize os pacotes do sistema para garantir que você tenha as últimas atualizações de segurança e software.
     ```bash
     sudo yum update -y
     ```

2. **Instalar Dependências**
   - Instale as dependências necessárias, como `wget` e `tar`.
     ```bash
     sudo yum install wget tar -y
     ```

### Passo 2: Instalar o Prometheus

1. **Baixar o Prometheus**
   - Baixe a versão mais recente do Prometheus.
     ```bash
     wget https://github.com/prometheus/prometheus/releases/download/v2.54.1/prometheus-2.54.1.linux-amd64.tar.gz
     ```

2. **Extrair o Prometheus**
   - Extraia o arquivo baixado.
     ```bash
     tar xvfz prometheus-2.54.1.linux-amd64.tar.gz
     ```

3. **Mover os Binários e Arquivos de Configuração**
   - Mova os binários do Prometheus e o `promtool` para `/usr/local/bin/`.
     ```bash
     sudo cp prometheus-2.54.1.linux-amd64/prometheus /usr/local/bin/
     sudo cp prometheus-2.54.1.linux-amd64/promtool /usr/local/bin/
     ```
   - Crie um diretório para os arquivos de configuração do Prometheus e mova-os para lá.
     ```bash
     sudo mkdir /etc/prometheus
     sudo cp -r prometheus-2.54.1.linux-amd64/consoles /etc/prometheus
     sudo cp -r prometheus-2.54.1.linux-amd64/console_libraries /etc/prometheus
     sudo cp prometheus-2.54.1.linux-amd64/prometheus.yml /etc/prometheus/prometheus.yml
     ```

4. **Criar um Diretório de Dados para o Prometheus**
   - Crie um diretório para armazenar os dados do Prometheus.
     ```bash
     sudo mkdir /var/lib/prometheus
     ```

### Passo 3: Configurar o Prometheus como um Serviço Systemd

1. **Criar um Usuário para o Prometheus**
   - Crie um usuário sem privilégios para executar o Prometheus.
     ```bash
     sudo useradd --no-create-home --shell /bin/false prometheus
     ```

2. **Configurar Permissões**
   - Defina as permissões apropriadas nos diretórios e arquivos do Prometheus.
     ```bash
     sudo chown -R prometheus:prometheus /etc/prometheus
     sudo chown -R prometheus:prometheus /var/lib/prometheus
     chown prometheus:prometheus /usr/local/bin/prometheus
     chown prometheus:prometheus /usr/local/bin/promtool
     chown -R prometheus:prometheus /etc/prometheus
     ```

3. **Criar o Arquivo de Serviço Systemd**
   - Crie um arquivo de serviço systemd para gerenciar o Prometheus.
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

### Passo 4: Iniciar e Verificar o Prometheus

1. **Recarregar o Systemd**
   - Recarregue o systemd para aplicar as mudanças.
     ```bash
     sudo systemctl daemon-reload
     ```

2. **Iniciar o Serviço Prometheus**
   - Inicie o serviço do Prometheus.
     ```bash
     sudo systemctl start prometheus
     ```

3. **Habilitar o Serviço para Iniciar Automaticamente**
   - Habilite o serviço para iniciar automaticamente na inicialização do sistema.
     ```bash
     sudo systemctl enable prometheus
     ```

4. **Verificar o Status do Serviço**
   - Verifique se o serviço está em execução.
     ```bash
     sudo systemctl status prometheus
     ```

### Passo 5: Configurar o Prometheus

1. **Editar o Arquivo de Configuração do Prometheus**
   - Edite o arquivo `/etc/prometheus/prometheus.yml` conforme suas necessidades. Por exemplo, para adicionar um target do Node Exporter:
     ```yaml
     global:
       scrape_interval: 15s

     scrape_configs:
       - job_name: 'node_exporter'
         static_configs:
           - targets: ['<IP_DO_SEU_SERVIDOR>:9100']
     ```

2. **Reiniciar o Prometheus para Aplicar as Mudanças**
   - Reinicie o serviço Prometheus para aplicar as mudanças na configuração.
     ```bash
     sudo systemctl restart prometheus
     ```

### Passo 6: Acessar a Interface Web do Prometheus

- A interface web do Prometheus estará disponível em `http://<IP_DO_SEU_SERVIDOR>:9090`.


