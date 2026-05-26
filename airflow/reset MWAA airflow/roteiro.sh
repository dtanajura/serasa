# Verificar os logs do WebServer no CloudWatch
# Acesse os logs do grupo: airflow-airflow-mwaa-nike-dcf-prod-WebServer

<#
O erro que você está enfrentando na UI do Airflow no Amazon MWAA — AttributeError: 'NoneType' object has no attribute 'get' — está relacionado ao sistema de autenticação do Airflow, especificamente ao Flask-Login. Esse erro geralmente ocorre quando a sessão do usuário não está sendo corretamente inicializada ou está corrompida.
#>

aws mwaa update-environment `
  --name airflow-mwaa-nike-dcf-prod `
  --airflow-configuration-options file://airflow-config.json `
  --profile dsprod

# Monitoramento:

# https://sa-east-1.console.aws.amazon.com/cloudwatch/deeplink.js?region=sa-east-1#metricsV2:graph=~%28metrics~%28~%28~'AWS*2fMWAA~'CPUUtilization~'Cluster~'WebServer~'Environment~'airflow-mwaa-nike-dcf-prod%29%29~stat~'Maximum~period~300~start~'2025-11-05T02*3a41*3a10Z~end~'2025-11-08T02*3a41*3a10Z~region~'sa-east-1%29

# https://sa-east-1.console.aws.amazon.com/cloudwatch/home?region=sa-east-1#metricsV2?graph=~(metrics~(~(~'AWS*2fMWAA~'CPUUtilization~'Cluster~'WebServer~'Environment~'airflow-mwaa-nike-dcf-prod)~(~'...~'Scheduler~'.~'.)~(~'...~'AdditionalWorker~'.~'.))~stat~'Maximum~period~60~start~'-PT12H~end~'P0D~region~'sa-east-1~view~'timeSeries~stacked~false)&query=~'*7bAWS*2fMWAA*2cCluster*2cEnvironment*7d*20airflow-mwaa-nike-dcf-prod

<#
O problema é que a CPU dos workers está 100% o tempo todo e o ambiente fica instável desse jeito
#>

aws mwaa update-environment `
  --name airflow-mwaa-nike-dcf-prod `
  --airflow-configuration-options file://airflow-config.json `
  --profile dsprod `
  --environment-class mw1.large

# horário 00:14

aws mwaa get-environment `
   --name airflow-mwaa-nike-dcf-prod `
   --profile dsprod