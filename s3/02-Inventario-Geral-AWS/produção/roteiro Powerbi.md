# Configuração do PowerBI para acesso dos dados do Inventário
## Introdução
Esse é um roteiro descrevendo os passos para mapeamento dos dados de consumo das contas da AWS da BU Nike e análise desses dados no PowerBI

## Escopo de contas da NIKE na análise
### Lista de contas 
Apelido da Conta | Número AWS
-----------------|-----------------
corporateprod|564593125549
arcsandbox|187739130313
ssrmdev|306716481758
ssrmsandbox|087086536124
ssrmprod|877001948254
corporatedev|153056696998
sredev|504195663072
dsstage|146737708860
dsprod|662860092544
dsdev|530914589075
datahubdev|353091569218
datahubprod|415071355886
consentdev|992382670558
consentprod|975050357449

### Login nas contas
~~~
saml2aws.exe login -a eec-aws-br-nike-corporate-prod
saml2aws.exe login -a eec-aws-br-nike-architecture-sandbox
saml2aws.exe login -a eec-aws-br-nike-ssrm-dev
saml2aws.exe login -a eec-aws-br-nike-ss-sandbox
saml2aws.exe login -a eec-aws-br-nike-sales-prod
saml2aws.exe login -a eec-aws-br-nike-corporate-dev
saml2aws.exe login -a eec-aws-br-eits-nike-sre-management-dev
saml2aws.exe login -a eec-aws-br-ds-dataservices-stage
saml2aws.exe login -a eec-aws-br-ds-dataservices-prod
saml2aws.exe login -a eec-aws-br-ds-dataservices-dev
saml2aws.exe login -a eec-aws-us-eits-datahub-dev
saml2aws.exe login -a eec-aws-br-eits-datahub-prod 
saml2aws.exe login -a eec-aws-us-eits-consent-dev
saml2aws.exe login -a eec-aws-us-eits-consent-prod
~~~

## Banco de dados
Foi criado um banco de dados em um RDS Postgres com o nome *INVENTARIO*
### Criação do banco
#### Conectar no RDS
~~~
psql -h dev-hub-portal-qa.cbjrpisgumc2.sa-east-1.rds.amazonaws.com -p 5432 -U postgres -W -d postgres -W
~~~
### Criar o banco de dados
~~~~ SQL
CREATE DATABASE custos_nike;
CREATE TABLE accounts (
    account_id VARCHAR(12),
    account_profile VARCHAR(20),
    account_name VARCHAR(50),
    account_region VARCHAR(10),
    date_register date
);
ALTER TABLE accounts
ADD CONSTRAINT unique_account UNIQUE (account_id, account_profile, account_region);

CREATE TABLE account_costs (
    account_id VARCHAR(20),
    unblended_cost FLOAT,
    date_register date
);

CREATE TABLE resource_costs (
    account_id VARCHAR(20),
    service VARCHAR(50),
    unblended_cost FLOAT,
    date_register date
);

CREATE TABLE tag_costs (
    account_id VARCHAR(20),
    tag_name VARCHAR(100),
    unblended_cost FLOAT,
    date_register date
);

CREATE TABLE tag_details_costs (
    account_id VARCHAR(20),
    tag_name VARCHAR(100),
    service VARCHAR(50),
    unblended_cost FLOAT,
    date_register date
);
~~~~


### Criação do usuário da aplicação
~~~~ SQL
-- Criar usuário
CREATE USER app_user PASSWORD '12345abc';
-- Concede permissões para todas tabelas
DO
$do$
DECLARE
   tbl RECORD;
BEGIN
   FOR tbl IN
           SELECT tablename FROM pg_tables WHERE schemaname = 'public'
   LOOP
           EXECUTE format('GRANT SELECT ON TABLE public.%I TO app_user',tbl.tablename);
           EXECUTE format('GRANT INSERT ON TABLE public.%I TO app_user',tbl.tablename);
           EXECUTE format('GRANT UPDATE ON TABLE public.%I TO app_user',tbl.tablename);
           EXECUTE format('GRANT DELETE ON TABLE public.%I TO app_user',tbl.tablename);
   END LOOP;
END
$do$;
~~~~

## Script PYTHON
Na rotina Python extraimos informações das contas, especialmente do Inventário do AWS Config e do AWS Cost Explorer, que estão em várias funções no código. Essas funções capturam essas informações e escrevem os dados no banco de dados
~~~~ PYTHON
# Obtém o número da conta da AWS
session = boto3.Session(profile_name=account)
sts_client = session.client('sts')
account_id = sts_client.get_caller_identity()['Account']

# Define as regiões permitidas
permitted_regions = ['us-east-1','sa-east-1' ]
for permitted_region in permitted_regions:
    ec2 = session.client("ec2",region_name=permitted_region)
    response = ec2.describe_vpcs(Filters=[{'Name':'isDefault','Values': ['false']}])
    if response['Vpcs']:
        region=permitted_region
    
. . .

# Atualizando os dados da conta na tabela accounts
update_account(db_config,account_id,account)

# Atualizando custos mensais da conta
write_cost_by_account(db_config,session,account_id)

# Atualizando custos mensais dos serviços na conta
write_cost_by_services(db_config,session,account_id)

# Atualizando custos mensais das tags names na conta
write_cost_by_tags(db_config, session, account_id)

# Atualizando custos mensais das tags names na conta
write_cost_by_tags_details(db_config, session, account_id)

~~~~

## PowerBI
### Configurações iniciais no PowerBI
#### Acesso ao banco
##### Com certificado
1- Baixe o certificado RDS do site da AWS https://docs.aws.amazon.com/pt_br/AmazonRDS/latest/UserGuide/UsingWithRDS.SSL.html#UsingWithRDS.SSL.CertificatesAllRegions
2- No Windows, abra o "certmgr.msc", em "Autoridades de Certificação Raiz Confiáveis", "Certificados", e instale o certificado que vc baixou na etapa 1
3- No PowerBI, "obter dados", "Banco de Dados Postgres", informar endereço do servidor, nome do banco de dados, usuário e senha
##### Sem certificado
1- No PowerBI, "obter dados", "Banco de Dados Postgres", "Opções Avançadas", "Instrução SQL" e escreva _SSL Mode=Require; Trust Server Certificate=false;_
2- Informar endereço do servidor, nome do banco de dados, usuário e senha

