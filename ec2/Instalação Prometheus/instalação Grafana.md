### Passo 1: Preparar o Ambiente

1. **Atualizar o Sistema**
   - Atualize os pacotes do sistema para garantir que você tenha as últimas atualizações de segurança e software.
     ```bash
     sudo yum update -y
     ```

### Passo 2: Instalar o Grafana

1. **Adicionar o Repositório do Grafana**
   - Crie um arquivo de repositório para o Grafana.
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
     ```

2. **Instalar o Grafana**
   - Instale o Grafana usando o gerenciador de pacotes `yum`.
     ```bash
     sudo yum install grafana -y
     ```

### Passo 3: Iniciar e Habilitar o Serviço do Grafana

1. **Iniciar o Serviço do Grafana**
   - Inicie o serviço do Grafana.
     ```bash
     sudo systemctl start grafana-server
     ```

2. **Habilitar o Serviço para Iniciar Automaticamente**
   - Habilite o serviço do Grafana para iniciar automaticamente na inicialização do sistema.
     ```bash
     sudo systemctl enable grafana-server
     ```

3. **Verificar o Status do Serviço**
   - Verifique se o serviço do Grafana está em execução.
     ```bash
     sudo systemctl status grafana-server
     ```

### Passo 4: Configurar o Firewall

1. **Atualizar o Security Group na AWS**
   - Se você estiver usando um Security Group na AWS, certifique-se de adicionar uma regra para permitir o tráfego na porta 3000.

### Passo 5: Configurar o Grafana

1. **Acessar a Interface Web do Grafana**
   - No navegador, acesse o Grafana em `http://<IP_DO_SEU_SERVIDOR>:3000`.
   - Faça login com as credenciais padrão:
     - Usuário: `admin`
     - Senha: `admin`

2. **Alterar a Senha**
   - Após o login, você será solicitado a alterar a senha padrão.

3. **Adicionar o Data Source do Prometheus**
   - Vá para **Configuration** (ícone de engrenagem) > **Data Sources**.
   - Clique em **Add data source**.
   - Selecione **Prometheus**.
   - Configure o data source com a URL do Prometheus, por exemplo, `http://10.99.105.48:9090`.
   - Clique em **Save & Test** para garantir que o Grafana pode se conectar ao Prometheus.

### Passo 6: Criar um Dashboard

1. **Criar um Novo Dashboard**
   - Vá para **Create** (ícone de "+" na barra lateral) > **Dashboard**.
   - Clique em **Add new panel**.

2. **Configurar um Painel**
   - No painel de configuração, configure as métricas que você deseja visualizar a partir do Prometheus.
   - Por exemplo, para visualizar a utilização da CPU:
     - Em **Query**, selecione `Prometheus` como a fonte de dados.
     - Insira a seguinte consulta Prometheus:
       ```prometheus
       rate(node_cpu_seconds_total[1m])
       ```

3. **Salvar o Dashboard**
   - Depois de configurar os painéis conforme necessário, clique em **Apply** para salvar as alterações.
   - Dê um nome ao seu dashboard e salve-o.

### Conclusão

