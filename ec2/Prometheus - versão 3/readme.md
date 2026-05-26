# Roteiro uso das automações

## Conectar no Repositório
### 1. Autenticar no Bitbucket
- Abrir no navegador https://code.experian.local/projects/NIKESRE e fazer login no OKTA com o login da placa
- No meu caso vou criar serviços AWS na conta eec-aws-br-nike-architecture-sandbox, dessa forma devo selecionar:
    - Infrastructure
    - iac-eec-aws-br-nike-architecture-sandbox
- Nessa pasta, vou criar uma branch
    - Source -> Main -> Create Brunch From Here
    - Criar uma brunch com meu login de placa

### 2. Conectar com o GIT na máquina local
#### 2.1. Usar o https
Criar um clone do repositório
- Criar uma pasta local na sua estação para fazer a clonagem do repositório
- Pegar o endereço de clone da pasta (https) na página do Bitbucket
- Como vou fazer o clone via https, por conta da SERASA, preciso ignorar a verificação do certificado com o seguinte comando:
`` git config --global http.sslVerify false ``
- Fazer o Clone do repositório na máquina local
`` git clone https://code.experian.local/scm/nikesre/iac-eec-aws-br-nike-architecture-sandbox.git ``
- Alterar para a sua branch
`` git checkout c96531a ``
- Verificar a branch
`` git branch `` 

#### 2.2. Usar o ssh
Registrar o certificado
- Criar uma chave privada .pem e a chave pública de um certificado ssh (usar o openssl)
- No Bitbucket, acessar as configurações do projeto e criar uma nova chave na opção "access key" com a sua chave pública
- copiar o conteúdo da sua chave privada e adicionar no id_rsa que fica na pasta c:\usuarios\sua_placa\.ssh

Criar um clone do repositório
- Criar uma pasta local na sua estação para fazer a clonagem do repositório
- Pegar o endereço de clone da pasta (ssh) na página do Bitbucket
- Fazer o Clone do repositório na máquina local
`` git clone ssh://code.experian.local/scm/nikesre/iac-eec-aws-br-nike-architecture-sandbox.git ``
- Alterar para a sua branch
`` git checkout c96531a ``
- Verificar a branch
`` git branch `` 

### 3. Criar o código para provisionamento do serviço
- O código deve ficar na estrutura da pasta: 
    - Infrastructure -> Conta -> Region -> Service -> Your_Service_Name
- Os módulos do terraform ficam na pasta: 
    - Terraform -> terraform-service_name
- Arquivos a serem criados nessa pasta (ver documentação do módulo):
    - main.tf - usei um arquivo de outro serviço que foi provisionado na conta para as definições "terraform", "provider" e "locals" (com os valores das tags) e complementei com a chamada do módulo que copiei no arquivo de exemplo da pasta do módulo terraform, fazendo ajuste do "tag-version"
        - Para obter o "tag_version" a gente vai na pasta do módulo Terraform e seleciona "Main -> Tag -> vê o último tag"
    - variables.tf - no meu caso ficou vazia (não foi necessário declarar nenhuma variável) - isso pode depender do módulo do serviço que você vai implantar
    - outputs.tf - no meu caso ficou vazia (não foi necessário declarar nenhuma variável) - isso pode depender do módulo do serviço que você vai implantar
    - versions.tf - fiz uma cópia de outro serviço que havia sido implantado nessa conta
    - backend.hcl - fiz uma cópia de outro serviço que havia sido implantado nessa conta

### 4. Salvar os arquivos do repositório
- Ir para o diretório do repositório
`` cd c:\....\meu repositório ``
- Verificar arquivos que não foram adicionados
`` git status ``
- Adicionar arquivos ao repositório
`` git add . ``
- Fazer o commit dos dados para o repositório
`` git commit -m "Versão 0 - bucket s3 - 24.02 - 15:02" ``
- Transferir os arquivos alterados para a minha branch no repositório remoto
`` git push ``
    - no meu caso, precisei informar o usuário e senha





