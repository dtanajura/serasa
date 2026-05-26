### Passo 1: Atualizar o Sistema

1. **Atualizar os Pacotes do Sistema**
   - Primeiro, certifique-se de que todos os pacotes do sistema estão atualizados.

     ```sh
     sudo yum update -y
     ```

### Passo 2: Baixar e Instalar o Node Exporter

1. **Baixar o Node Exporter**
   - Baixe a versão mais recente do Node Exporter. No momento em que este guia foi escrito, a versão mais recente era a 1.5.0, mas você deve verificar a página do GitHub do Prometheus para a versão mais recente.

     ```sh
     wget https://github.com/prometheus/node_exporter/releases/download/v1.8.1/node_exporter-1.8.1.linux-amd64.tar.gz
     ```
# node_exporter-1.8.1.linux-arm64.tar.gz
2. **Extrair o Node Exporter**
   - Extraia o arquivo tar.gz que você acabou de baixar.

     ```sh
     tar xvfz node_exporter-1.8.1.linux-amd64.tar.gz
     ```

3. **Mover o Binário do Node Exporter**
   - Mova o binário `node_exporter` para `/usr/local/bin/`.

     ```sh
     sudo cp node_exporter-1.8.1.linux-amd64/node_exporter /usr/local/bin/
     ```

### Passo 3: Criar um Usuário para o Node Exporter

1. **Criar um Usuário sem Permissões de Login**
   - Crie um usuário dedicado para o Node Exporter.

     ```sh
     sudo useradd --no-create-home --shell /bin/false nodeusr
     ```

sudo chown nodeusr. /usr/local/bin/node_exporter 

### Passo 4: Configurar o Node Exporter como um Serviço Systemd

1. **Criar um Arquivo de Serviço para o Node Exporter**
   - Crie um arquivo de serviço systemd para gerenciar o Node Exporter.

     ```sh
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
     ```

2. **Iniciar e Habilitar o Serviço Node Exporter**
   - Recarregue o systemd para reconhecer o novo serviço, inicie o serviço e habilite-o para iniciar automaticamente na inicialização do sistema.

     ```sh
     sudo systemctl daemon-reload
     sudo systemctl start node_exporter
     sudo systemctl enable node_exporter
     ```

3. **Verificar o Status do Serviço**
   - Verifique se o serviço Node Exporter está em execução.

     ```sh
     sudo systemctl status node_exporter
     ```

### Passo 6: Verificar o Node Exporter

1. **Acessar as Métricas do Node Exporter**
   - No navegador, acesse `http://<IP_DO_SEU_SERVIDOR>:9100/metrics` para ver as métricas expostas pelo Node Exporter.

