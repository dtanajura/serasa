########### Comandos SQL
##### Criar uma tabela
CREATE TABLE tag_cost (
    account_id VARCHAR(20),
    tag_name VARCHAR(50),
    date_register  timestamp with time zone,
    date_simples  
    unblended_cost FLOAT
);

# Dar permissões (GRANT) para um usuário em uma tabela
GRANT SELECT ON TABLE account_cost TO "app-user";
GRANT INSERT ON TABLE account_cost TO "app-user";
GRANT UPDATE ON TABLE account_cost TO "app-user";
GRANT DELETE ON TABLE account_cost TO "app-user";

GRANT SELECT ON TABLE servicos TO "app-user";
GRANT INSERT ON TABLE servicos TO "app-user";
GRANT UPDATE ON TABLE servicos TO "app-user";
GRANT DELETE ON TABLE servicos TO "app-user";


##### Alterar campos da tabela
# Alterar um campo para o tipo caracter
ALTER TABLE tag_cost ALTER COLUMN tag_name TYPE VARCHAR(100);

# Alterar um campo para ser uma foreign key - possibilita o JOIN entre tabelas
ALTER TABLE resources ADD CONSTRAINT fk_account_id FOREIGN KEY (account_id) REFERENCES accounts (account_id);

# Criar uma primary key em uma tabela
alter table accounts ADD PRIMARY KEY (account_id);

# Tipo tempo (data e horário) com time zone 
ALTER TABLE resourcecost ALTER COLUMN register TYPE TIMESTAMP WITH TIME ZONE USING register AT TIME ZONE 'America/Sao_Paulo';

# Renomear uma coluna de uma tabela
ALTER TABLE resourcecost  RENAME COLUMN register TO date_register;

##### Criar uma nova coluna
# Tipo Texto
ALTER TABLE accounts ADD COLUMN account_aws VARCHAR(50);

# Tipo número
ALTER TABLE resourcecost ADD COLUMN unblended_cost FLOAT;

##### Dropar (deletar) uma coluna de uma tabela
ALTER TABLE resourcecost DROP COLUMN vlblendedcost;


##### Exemplos de Selects
# listar tabela 
SELECT * from resources;

# Básico
SELECT column_name, data_type, character_maximum_length FROM information_schema.columns WHERE table_name = 'resourcecost';

# Com a função COUNT
SELECT account, COUNT(account) FROM resources GROUP BY account 

# Delete de registros com WHERE
DELETE FROM accounts WHERE account_id = '187739130313';

# com Group By
SELECT account_id, service, SUM(unblended_cost) as soma FROM resourcecost GROUP BY account_id, service ORDER BY soma DESC;

# Montando strings e com JOIN
SELECT SUBSTRING(r.service FROM 1 FOR 20) || ' - ' || a.account_name, SUM(r.unblended_cost) as soma 
FROM resourcecost r 
JOIN accounts a ON r.account_id = a.account_id
WHERE a.account_name IN ($var_account_name)
GROUP BY r.account_id, a.account_name, r.service
ORDER BY soma DESC


##### Lista de tabelas relevantes
\dt
List of relations
 Schema |       Name        | Type  |  Owner
--------+-------------------+-------+----------
 public | account_costs     | table | postgres
 public | accounts          | table | postgres
 public | resource_costs    | table | postgres
 public | tag_costs         | table | postgres
 public | tag_details_costs | table | postgres
(5 rows)

# account_costs
SELECT column_name, data_type, character_maximum_length FROM information_schema.columns WHERE table_name = 'account_costs';
  column_name   |     data_type     | character_maximum_length
----------------+-------------------+--------------------------
 account_id     | character varying |                       20
 unblended_cost | double precision  |
 date_register  | date              |
(3 rows)
truncate table account_costs;

ALTER TABLE account_costs ADD CONSTRAINT unique_account_date UNIQUE (account_id, date_register);
DELETE FROM account_costs WHERE account_id = '564593125549' AND date_trunc('month',date_register) = '2024-05-01';
UPDATE account_costs SET unblended_cost = 100000 WHERE account_costs.date_register = '2024-06-30';

# accounts
SELECT column_name, data_type, character_maximum_length FROM information_schema.columns WHERE table_name = 'accounts';
   column_name   |     data_type     | character_maximum_length
-----------------+-------------------+--------------------------
 account_id      | character varying |                       12
 account_profile | character varying |                       20
 account_name    | character varying |                       50
 account_region  | character varying |                       10
 date_register   | date              |
(5 rows)
truncate table accounts;

# resource_costs
SELECT column_name, data_type, character_maximum_length FROM information_schema.columns WHERE table_name = 'resource_costs';
  column_name   |     data_type     | character_maximum_length
----------------+-------------------+--------------------------
 account_id     | character varying |                       20
 service        | character varying |                       50
 unblended_cost | double precision  |
 date_register  | date              |
(4 rows)
ALTER TABLE resource_costs ADD CONSTRAINT unique_account_service_date UNIQUE (account_id, service, date_register);
# Excuir todos registros de uma tabela
truncate table resource_costs;
UPDATE resource_costs SET unblended_cost = 100000 WHERE resource_costs.date_register = '2024-06-30';

# tag_costs
SELECT column_name, data_type, character_maximum_length FROM information_schema.columns WHERE table_name = 'tag_costs';
  column_name   |     data_type     | character_maximum_length
----------------+-------------------+--------------------------
 account_id     | character varying |                       20
 tag_name       | character varying |                      100
 unblended_cost | double precision  |
 date_register  | date              |
(4 rows)
ALTER TABLE tag_costs ADD CONSTRAINT unique_account_tag_date UNIQUE (account_id, tag_name, date_register);
truncate table tag_costs;

# tag_details_costs
SELECT column_name, data_type, character_maximum_length FROM information_schema.columns WHERE table_name = 'tag_details_costs';
  column_name   |     data_type     | character_maximum_length
----------------+-------------------+--------------------------
 account_id     | character varying |                       20
 tag_name       | character varying |                      100
 service        | character varying |                       50
 unblended_cost | double precision  |
 date_register  | date              |
(5 rows)
ALTER TABLE tag_details_costs ADD CONSTRAINT unique_account_tag_service_date UNIQUE (account_id, tag_name, service, date_register);
truncate table tag_details_costs;


################################
### QUERIES DOS DASHBOARDS
################################

#### Dashboard Contas
### Variável Contas
SELECT DISTINCT account_name FROM accounts ORDER BY account_name;

### Variável Serviço
SELECT DISTINCT service FROM resource_costs ORDER BY service;

### Variável Mês
SELECT DISTINCT TO_CHAR(date_register, 'YYYY-MM') as month FROM resource_costs ORDER BY month;

### Quantidade de contas
SELECT count(account_id) FROM accounts WHERE account_name IN ( $var_contas  )

### Ultimo Scan
SELECT TO_CHAR(max(date_register), 'DD/MM/YY') FROM accounts WHERE account_name IN ( $var_contas  );

### Top Valor
SELECT 
  concat(a.account_name, CHR(10), to_char(SUM(ac.unblended_cost), 'US$FM999G999G999D00')) AS display_text, 
  SUM(ac.unblended_cost) AS total_cost, TO_CHAR(ac.date_register, 'Mon-YY') AS month_name
FROM 
  account_costs ac
JOIN 
  accounts a ON ac.account_id = a.account_id
WHERE 
  TO_CHAR(ac.date_register, 'YYYY-MM') = '${var_meses}' 
  AND a.account_name IN ( $var_contas  )
GROUP BY 
  a.account_name,  
  ac.account_id, 
  TO_CHAR(ac.date_register, 'YYYY-MM'), 
  TO_CHAR(ac.date_register, 'Mon-YY')
ORDER BY 
  total_cost DESC
LIMIT 1;

###  valor da conta mês a mês
select 
  TO_CHAR(date_register, 'YYYY-MM') AS month, 
  TO_CHAR(date_register, 'Mon-YY') AS month_name, 
  sum(unblended_cost) 
from 
  account_costs 
group by 
  TO_CHAR(date_register, 'YYYY-MM'), 
  TO_CHAR(date_register, 'Mon-YY') 
order by 
  TO_CHAR(date_register, 'YYYY-MM') desc;

### Top 3 contas dos últimos 3 meses
WITH ranked_costs AS (
    SELECT
        a.account_profile,
        TO_CHAR(ac.date_register, 'YYYY-MM') AS month,
        SUM(ac.unblended_cost) AS total_cost,
        DENSE_RANK() OVER (PARTITION BY TO_CHAR(ac.date_register, 'YYYY-MM') ORDER BY SUM(ac.unblended_cost) DESC) AS rank
    FROM
        account_costs ac
    JOIN
        accounts a ON ac.account_id = a.account_id
    GROUP BY
        a.account_profile,
        TO_CHAR(ac.date_register, 'YYYY-MM')
)
SELECT
    month,
    account_profile,
    total_cost
FROM
    ranked_costs
WHERE
    rank <= 3
ORDER BY
    month DESC,
    rank
LIMIT 9;

#### Dashboard de Serviços
### Variável var_contas
SELECT DISTINCT account_name FROM accounts ORDER BY account_name;

### Variavel var_servicos
SELECT DISTINCT service FROM resource_costs ORDER BY service;

### Variável var_meses
SELECT DISTINCT TO_CHAR(date_register, 'YYYY-MM') as month FROM resource_costs ORDER BY month DESC;

### Variável var_ultimo_mes
SELECT TO_CHAR(MAX(date_register), 'YYYY-MM') as month FROM resource_costs;

### Serviços analisados
select count(distinct(service)) from resource_costs;

### Top Servico
SELECT concat(service, CHR(10), to_char(sum(unblended_cost), 'US$FM999G999G999D00')) as display_text, sum(unblended_cost) as total_cost 
FROM resource_costs 
WHERE TO_CHAR(date_register, 'YYYY-MM') = '${var_meses}' 
GROUP BY service 
ORDER BY total_cost DESC
LIMIT 1;

#### distribuicao custo dos serviços no mês
SELECT s.short_name, sum(rc.unblended_cost) AS total_cost
FROM resource_costs rc
JOIN servicos s ON rc.service = s.service
WHERE TO_CHAR(rc.date_register, 'YYYY-MM') = '${var_meses}'
GROUP BY s.short_name
ORDER BY total_cost DESC;

# Custo dos serviços mes a mes
SELECT 
  TO_CHAR(rc.date_register, 'YYYY-MM') AS month,
  TO_CHAR(rc.date_register, 'Mon-YY') AS month_name, 
  s.short_name, 
  sum(rc.unblended_cost) as total_cost
FROM 
  resource_costs rc
JOIN 
  accounts a ON rc.account_id = a.account_id
JOIN
  servicos s ON rc.service = s.service
WHERE 
  rc.service IN ($var_servicos) 
  AND a.account_name IN ($var_contas)
GROUP BY
  TO_CHAR(rc.date_register, 'YYYY-MM'), 
  TO_CHAR(rc.date_register, 'Mon-YY'), 
  s.short_name
ORDER BY 
  TO_CHAR(rc.date_register, 'YYYY-MM') desc;

### Top serviços nos ultimos 3 meses
WITH ranked_costs AS (
    SELECT
        s.short_name as service,
        TO_CHAR(rc.date_register, 'YYYY-MM') AS month,
        SUM(rc.unblended_cost) AS total_cost,
        DENSE_RANK() OVER (PARTITION BY TO_CHAR(rc.date_register, 'YYYY-MM') ORDER BY SUM(rc.unblended_cost) DESC) AS rank
    FROM
        resource_costs rc
    JOIN
        servicos s ON rc.service = s.service
    GROUP BY
        s.short_name,
        TO_CHAR(rc.date_register, 'YYYY-MM')
)
SELECT
    month,
    service,
    total_cost
FROM
    ranked_costs
WHERE
    rank <= 6
ORDER BY
    month DESC,
    rank
LIMIT 18;

### Grafico das Tags
# Tags analisadas
SELECT
  count(distinct(tdc.tag_name)) 
FROM
  tag_details_costs tdc 
JOIN
  accounts a ON tdc.account_id = a.account_id
WHERE 
  tdc.service IN ( $var_servicos ) AND 
  a.account_name IN ( $var_contas )

# Top valor
SELECT 
  concat(tdc.tag_name, CHR(10), to_char(sum(tdc.unblended_cost), 'US$FM999G999G999D00')) as display_text, 
  sum(tdc.unblended_cost) as total_cost 
FROM 
  tag_details_costs tdc
JOIN
  accounts a ON tdc.account_id = a.account_id
WHERE 
  TO_CHAR(tdc.date_register, 'YYYY-MM') = '${var_meses}' AND 
  tdc.service IN ( $var_servicos ) AND
  a.account_name IN ( $var_contas )
GROUP BY 
  tdc.tag_name
ORDER BY 
  total_cost DESC
LIMIT 1;

# Top 10 tags no mês - pizza
SELECT 
  CASE 
      WHEN LENGTH(tdc.tag_name) > 10 THEN
          substring(tdc.tag_name FROM 1 FOR 5) || '...' || substring(tdc.tag_name FROM LENGTH(tdc.tag_name) - 4)
      ELSE
          tdc.tag_name
  END AS short_tag_name,
  SUM(tdc.unblended_cost) AS total_cost
FROM 
  tag_details_costs tdc
JOIN
  accounts a ON tdc.account_id = a.account_id
WHERE 
  TO_CHAR(tdc.date_register, 'YYYY-MM') = '${var_meses}' 
  AND tdc.service IN (${var_servicos})
  AND a.account_name IN ( $var_contas )
GROUP BY 
    short_tag_name
ORDER BY 
    total_cost DESC
LIMIT 10;

# Top 10 tags no mês - tabela
SELECT 
  tdc.tag_name as short_tag_name, SUM(tdc.unblended_cost) AS total_cost
FROM 
  tag_details_costs tdc
JOIN
  accounts a ON tdc.account_id = a.account_id
WHERE 
  TO_CHAR(tdc.date_register, 'YYYY-MM') = '${var_meses}' 
  AND tdc.service IN (${var_servicos})
  AND a.account_name IN ( $var_contas )
GROUP BY 
    short_tag_name
ORDER BY 
    total_cost DESC
LIMIT 10;

# Custo Tags mês a mês nas contas
SELECT 
  TO_CHAR(tdc.date_register, 'YYYY-MM') AS month,
  a.account_profile,
  CASE 
      WHEN LENGTH(tdc.tag_name) > 10 THEN
          substring(tdc.tag_name FROM 1 FOR 5) || '...' || substring(tdc.tag_name FROM LENGTH(tdc.tag_name) - 4)
      ELSE
          tdc.tag_name
  END AS short_tag_name,
  sum(tdc.unblended_cost) as total_cost
FROM 
  tag_details_costs tdc
JOIN 
  accounts a ON tdc.account_id = a.account_id
WHERE 
  tdc.tag_name = '$var_tags'
  AND tdc.service IN (${var_servicos})
  AND a.account_name IN ($var_contas)
GROUP BY
  TO_CHAR(tdc.date_register, 'YYYY-MM'), 
  a.account_profile,
  tdc.tag_name
ORDER BY 
  TO_CHAR(tdc.date_register, 'YYYY-MM') desc;

# Top tags nos últimos 3 meses
SELECT 
  TO_CHAR(tdc.date_register, 'YYYY-MM') AS month,
  a.account_profile,
  CASE 
      WHEN LENGTH(tdc.tag_name) > 10 THEN
          substring(tdc.tag_name FROM 1 FOR 5) || '...' || substring(tdc.tag_name FROM LENGTH(tdc.tag_name) - 4)
      ELSE
          tdc.tag_name
  END AS short_tag_name,
  sum(tdc.unblended_cost) as total_cost
FROM 
  tag_details_costs tdc
JOIN 
  accounts a ON tdc.account_id = a.account_id
WHERE 
  tdc.tag_name = '$var_tags'
  AND tdc.service IN (${var_servicos})
  AND a.account_name IN ($var_contas)
GROUP BY
  TO_CHAR(tdc.date_register, 'YYYY-MM'), 
  a.account_profile,
  tdc.tag_name
ORDER BY 
  TO_CHAR(tdc.date_register, 'YYYY-MM') desc;


CREATE TABLE IF NOT EXISTS eks_clusters (
    account_id VARCHAR(20),
    cluster_id VARCHAR(20),
    cluster_name VARCHAR(50) UNIQUE,
    kubernetes_version VARCHAR(10)
);

CREATE TABLE IF NOT EXISTS eks_nodegroups (
    cluster_id VARCHAR(20),
    nodegroup_id VARCHAR(100)  UNIQUE,
    autoscaling_group_name VARCHAR(255),
    launch_template_id VARCHAR(20),
    launch_template_version VARCHAR(10)
);

CREATE TABLE IF NOT EXISTS eks_nodes (
    cluster_id VARCHAR(20),
    nodegroup_id VARCHAR(100)  UNIQUE,
    instance_id VARCHAR(20)
);

account_id     | character varying |                       20

CREATE TABLE tag_cost (
    account_id VARCHAR(20),
    tag_name VARCHAR(50),
    date_register  timestamp with time zone,
    date_simples  
    unblended_cost FLOAT
);

DO $$ 
DECLARE 
    r RECORD;
BEGIN 
    FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP 
        EXECUTE 'GRANT SELECT, UPDATE, DELETE, INSERT, TRUNCATE ON TABLE ' || quote_ident(r.tablename) || ' TO app-user';
    END LOOP;
END $$;

SELECT 
    to_char(t.date_register, 'YYYY-MM') AS month, 
    SUM(t.unblended_cost) AS cost
FROM 
    tag_details_costs t
JOIN 
    accounts a ON t.account_id = a.account_id
JOIN 
    servicos s ON t.service = s.short_name
WHERE 
    a.account_name = 'eec-aws-br-cs-bi-bns-uat'
    AND s.short_name = 'RDS'
    AND t.tag_name = 'cs-db-business-config-report-uat'
    AND t.date_register BETWEEN '2023-12-01' AND '2024-11-30'
GROUP BY 
    month
ORDER BY 
    month;


SELECT 
    i.instance_id
FROM
    instances i
JOIN
    vpcs v ON i.vpc_id = v.vpc_id
JOIN
    accounts a ON v.account_id = a.account_id
WHERE
    a.account_name = 'eec-aws-br-nike-corporate-prod';


SELECT 
    i.instance_id,
    i.tag_name,
    i.os,
    i.private_ip,
    i.public_ip,
    i.ami_name,
    i.instance_type,
    i.tag_env,
    i.tag_instance_sched
FROM
    instances i
JOIN
    subnets s ON s.subnet_id = i.subnet_id
JOIN
    vpcs v ON v.vpc_id = i.vpc_id
JOIN
    accounts a ON v.account_id = a.account_id
WHERE
    s.subnet_name = 'aws-landing-zone-PrivateSubnet3A'
    AND v.vpc_name = 'aws-landing-zone-VPC' 
    AND a.account_name = 'eec-aws-br-nike-corporate-prod'
;


CREATE TABLE emr (
    cluster_id VARCHAR(50) PRIMARY KEY,
    cluster_name VARCHAR(255),
    cluster_start TIMESTAMP,
    cluster_end TIMESTAMP,
    date_register date,
    account_id VARCHAR(20)
);

-- Criação da tabela emr_instancias
CREATE TABLE emr_instancias (
    instance_id VARCHAR(50) PRIMARY KEY,
    cluster_id VARCHAR(255) REFERENCES emr(cluster_id),
    instance_type VARCHAR(255)
);

# CONSULTA DASHBOARD INSTANCIAS EMR COM CUSTO 08.04
WITH intervals AS (
    SELECT 
        e.cluster_name,
        e.cluster_start AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo' AS start_time,
        e.cluster_end AT TIME ZONE 'UTC' AT TIME ZONE 'America/Sao_Paulo' AS end_time,
        EXTRACT(EPOCH FROM COALESCE(e.cluster_end, NOW()) - e.cluster_start) / 3600 AS duration_hours
    FROM 
        emr e
    JOIN 
        accounts a ON e.account_id = a.account_id
    WHERE 
        e.date_register = '$var_date' AND a.account_name = '$var_account_name'
),
instance_types AS (
    SELECT 
        e.cluster_name,
        ei.instance_type,
        COUNT(ei.instance_type) AS instance_count,
        ROW_NUMBER() OVER (PARTITION BY e.cluster_name ORDER BY ei.instance_type) AS rn
    FROM 
        emr e
    JOIN 
        emr_instancias ei ON e.cluster_id = ei.cluster_id
    JOIN 
        accounts a ON e.account_id = a.account_id
    WHERE 
        e.date_register = '2025-03-27' AND a.account_name = 'eec-aws-br-ds-dataservices-stage'
    GROUP BY 
        e.cluster_name, ei.instance_type
),
instance_prices AS (
    SELECT 
        itc.instance_type,
        itc.hourly_rate
    FROM 
        instances_type_caracteristics itc
)
SELECT 
    DISTINCT i.cluster_name,
    MAX(CASE WHEN ic.rn = 1 THEN ic.instance_type ELSE '-' END) AS instance_type_1,
    MAX(CASE WHEN ic.rn = 1 THEN ic.instance_count ELSE 0 END) AS qtd_instance_type_1,
    MAX(CASE WHEN ic.rn = 2 THEN ic.instance_type ELSE '-' END) AS instance_type_2,
    MAX(CASE WHEN ic.rn = 2 THEN ic.instance_count ELSE 0 END) AS qtd_instance_type_2,
    MAX(CASE WHEN ic.rn = 3 THEN ic.instance_type ELSE '-' END) AS instance_type_3,
    MAX(CASE WHEN ic.rn = 3 THEN ic.instance_count ELSE 0 END) AS qtd_instance_type_3,
    MAX(CASE WHEN ic.rn = 1 THEN ip.hourly_rate ELSE 0 END) AS price_hour_type_1,
    MAX(CASE WHEN ic.rn = 2 THEN ip.hourly_rate ELSE 0 END) AS price_hour_type_2,
    MAX(CASE WHEN ic.rn = 3 THEN ip.hourly_rate ELSE 0 END) AS price_hour_type_3,
    ROUND(SUM(i.duration_hours::numeric), 2) AS total_duration_hours,
    ROUND(
        SUM(i.duration_hours::numeric) * (
            MAX(CASE WHEN ic.rn = 1 THEN ic.instance_count ELSE 0 END) * MAX(CASE WHEN ic.rn = 1 THEN ip.hourly_rate ELSE 0 END)::numeric +
            MAX(CASE WHEN ic.rn = 2 THEN ic.instance_count ELSE 0 END) * MAX(CASE WHEN ic.rn = 2 THEN ip.hourly_rate ELSE 0 END)::numeric +
            MAX(CASE WHEN ic.rn = 3 THEN ic.instance_count ELSE 0 END) * MAX(CASE WHEN ic.rn = 3 THEN ip.hourly_rate ELSE 0 END)::numeric
        )::numeric, 2
    ) AS total_cost
FROM 
    intervals i
LEFT JOIN 
    instance_types ic ON i.cluster_name = ic.cluster_name
LEFT JOIN 
    instance_prices ip ON ic.instance_type = ip.instance_type
GROUP BY 
    i.cluster_name
ORDER BY 
    i.cluster_name;


SELECT column_name, data_type, character_maximum_length FROM information_schema.columns WHERE table_name = 'emr';

-- 1. Excluir todos os registros existentes
DELETE FROM accounts;

-- 2. Inserir os registros válidos
INSERT INTO accounts (account_id, account_profile, account_name, account_region, date_register) VALUES
('290856541169', 'bnsprod', 'eec-aws-br-cs-bi-bns-prod', 'sa-east-1', CURRENT_DATE),
('981433503269', 'bnsuat', 'eec-aws-br-cs-bi-bns-uat', 'sa-east-1', CURRENT_DATE),
('916546429908', 'dodev', 'eec-aws-br-ds-dataoffice-dev', 'sa-east-1', CURRENT_DATE),
('484240119361', 'douat', 'eec-aws-br-ds-dataoffice-uat', 'sa-east-1', CURRENT_DATE),
('530914589075', 'dsdev', 'eec-aws-br-ds-dataservices-dev', 'sa-east-1', CURRENT_DATE),
('662860092544', 'dsprod', 'eec-aws-br-ds-dataservices-prod', 'sa-east-1', CURRENT_DATE),
('146737708860', 'dsstage', 'eec-aws-br-ds-dataservices-stage', 'sa-east-1', CURRENT_DATE),
('105794972139', 'positivoprod', 'eec-aws-br-ds-positivo-prod', 'sa-east-1', CURRENT_DATE),
('728313149008', 'positivouat', 'eec-aws-br-ds-positivo-uat', 'sa-east-1', CURRENT_DATE),
('380979651404', 'architecture-sandbox', 'eec-aws-br-eits-architecture-sandbox', 'sa-east-1', CURRENT_DATE),
('730335661246', 'datahubdev', 'eec-aws-br-eits-datahub-dev', 'sa-east-1', CURRENT_DATE),
('415071355886', 'datahubprod', 'eec-aws-br-eits-datahub-prod', 'sa-east-1', CURRENT_DATE),
('186041780552', 'lab01', 'eec-aws-br-eits-dx-lab01-sandbox', 'sa-east-1', CURRENT_DATE),
('504195663072', 'sredev', 'eec-aws-br-eits-nike-sre-management-dev', 'sa-east-1', CURRENT_DATE),
('050752636274', 'nikedatadev', 'eec-aws-br-eits-nikedataservice-dev', 'sa-east-1', CURRENT_DATE),
('225989352496', 'nikedataprod', 'eec-aws-br-eits-nikedataservice-prod', 'sa-east-1', CURRENT_DATE),
('713881783816', 'nikedatauat', 'eec-aws-br-eits-nikedataservice-uat', 'sa-east-1', CURRENT_DATE),
('187739130313', 'arcsandbox', 'eec-aws-br-nike-architecture-sandbox', 'sa-east-1', CURRENT_DATE),
('153056696998', 'corporatedev', 'eec-aws-br-nike-corporate-dev', 'sa-east-1', CURRENT_DATE),
('564593125549', 'corporateprod', 'eec-aws-br-nike-corporate-prod', 'sa-east-1', CURRENT_DATE),
('877001948254', 'ssrmprod', 'eec-aws-br-nike-sales-prod', 'sa-east-1', CURRENT_DATE),
('087086536124', 'ssrmsandbox', 'eec-aws-br-nike-ss-sandbox', 'sa-east-1', CURRENT_DATE),
('306716481758', 'ssrmdev', 'eec-aws-br-nike-ssrm-dev', 'sa-east-1', CURRENT_DATE),
('300374333803', 'negativodev', 'eec-aws-us-eits-negativo-dev', 'us-east-1', CURRENT_DATE),
('016592541791', 'negativoprivado', 'eec-aws-us-eits-negativoprivado-sandbox', 'us-east-1', CURRENT_DATE),
('109804294614', 'positivodev', 'eec-aws-us-eits-positivo-dev', 'us-east-1', CURRENT_DATE);

ALTER TABLE accounts ADD COLUMN account_group TEXT;

UPDATE accounts SET account_group = 'Nike'
WHERE account_id IN (
  '530914589075',
  '146737708860',
  '662860092544',
  '981433503269',
  '050752636274',
  '713881783816'
);

-- Atualiza grupo Reports V3
UPDATE accounts SET account_group = 'Reports V3'
WHERE account_id IN (
  '981433503269',
  '290856541169'
);

-- Atualiza grupo SSRM
UPDATE accounts SET account_group = 'SSRM'
WHERE account_id IN (
  '306716481758',
  '087086536124',
  '877001948254'
);

-- Atualiza grupo DataHub
UPDATE accounts SET account_group = 'DataHub'
WHERE account_id IN (
  '730335661246',
  '415071355886'
);
