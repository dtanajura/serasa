###################COMMONS########################################
Buckets:
athena-log-update
athenalogprod
aws-logs-662860092544-sa-east-1
dataservices-airflow-dags-prod
experian-datahub-checkpoint-prod
experian-datahub-config-files-prod
experian-datahub-landing-zone-prod
grafana-athena-nike
replication-lambda-exclude-versions-glue-prod
replication-lambda-nike-monitoring-checkpoint-prod
experian-datahub-validation
experian-replication-lambda-external-notification-prod
 
 
TAGs:
BU -> EITS
Layer -> Commons
Project -> Nike reports
Squad -> DcF
Dataset -> Commons

Commons
aws s3api put-bucket-tagging --bucket athena-log-update --tagging 'TagSet=[{Key=BU,Value=EITS},{Key=Layer,Value=Commons},{Key=Project,Value=Nike reports},{Key=Squad,Value=DcF},{Key=Dataset,Value=Commons}]'
aws s3api put-bucket-tagging --bucket athenalogprod --tagging 'TagSet=[{Key=BU,Value=EITS},{Key=Layer,Value=Commons},{Key=Project,Value=Nike reports},{Key=Squad,Value=DcF},{Key=Dataset,Value=Commons}]'
aws s3api put-bucket-tagging --bucket aws-logs-662860092544-sa-east-1 --tagging 'TagSet=[{Key=BU,Value=EITS},{Key=Layer,Value=Commons},{Key=Project,Value=Nike reports},{Key=Squad,Value=DcF},{Key=Dataset,Value=Commons}]'
aws s3api put-bucket-tagging --bucket dataservices-airflow-dags-prod --tagging 'TagSet=[{Key=BU,Value=EITS},{Key=Layer,Value=Commons},{Key=Project,Value=Nike reports},{Key=Squad,Value=DcF},{Key=Dataset,Value=Commons}]'
aws s3api put-bucket-tagging --bucket experian-datahub-checkpoint-prod --tagging 'TagSet=[{Key=BU,Value=EITS},{Key=Layer,Value=Commons},{Key=Project,Value=Nike reports},{Key=Squad,Value=DcF},{Key=Dataset,Value=Commons}]'
aws s3api put-bucket-tagging --bucket experian-datahub-config-files-prod --tagging 'TagSet=[{Key=BU,Value=EITS},{Key=Layer,Value=Commons},{Key=Project,Value=Nike reports},{Key=Squad,Value=DcF},{Key=Dataset,Value=Commons}]'
aws s3api put-bucket-tagging --bucket experian-datahub-landing-zone-prod --tagging 'TagSet=[{Key=BU,Value=EITS},{Key=Layer,Value=Commons},{Key=Project,Value=Nike reports},{Key=Squad,Value=DcF},{Key=Dataset,Value=Commons}]'
aws s3api put-bucket-tagging --bucket grafana-athena-nike --tagging 'TagSet=[{Key=BU,Value=EITS},{Key=Layer,Value=Commons},{Key=Project,Value=Nike reports},{Key=Squad,Value=DcF},{Key=Dataset,Value=Commons}]'
aws s3api put-bucket-tagging --bucket replication-lambda-exclude-versions-glue-prod --tagging 'TagSet=[{Key=BU,Value=EITS},{Key=Layer,Value=Commons},{Key=Project,Value=Nike reports},{Key=Squad,Value=DcF},{Key=Dataset,Value=Commons}]'
aws s3api put-bucket-tagging --bucket replication-lambda-nike-monitoring-checkpoint-prod --tagging 'TagSet=[{Key=BU,Value=EITS},{Key=Layer,Value=Commons},{Key=Project,Value=Nike reports},{Key=Squad,Value=DcF},{Key=Dataset,Value=Commons}]'
aws s3api put-bucket-tagging --bucket experian-datahub-validation --tagging 'TagSet=[{Key=BU,Value=EITS},{Key=Layer,Value=Commons},{Key=Project,Value=Nike reports},{Key=Squad,Value=DcF},{Key=Dataset,Value=Commons}]'
aws s3api put-bucket-tagging --bucket experian-replication-lambda-external-notification-prod --tagging 'TagSet=[{Key=BU,Value=EITS},{Key=Layer,Value=Commons},{Key=Project,Value=Nike reports},{Key=Squad,Value=DcF},{Key=Dataset,Value=Commons}]'

###################Bronze Negativos#####################################
Buckets:
experian-datahub-bronze-prod
experian-datahub-kafkalog-prod
experian-datahub-kafkalog-v2-prod
 
TAGs:
BU -> EITS
Layer -> Bronze
Project -> Nike reports
Squad -> DcF
Dataset -> Negativos
 
###################Silver Negativos####################################
Buckets:
experian-datahub-silver-prod
 
TAGs:
BU -> EITS
Layer -> Silver
Project -> Nike reports
Squad -> DcF
Dataset -> Negativos
 
###################Gold Negativos####################################
Buckets:
experian-datahub-gold-reports-prod
experian-dataservices-reports-artifacts-prod
 
TAGs:
BU -> EITS
Layer -> Gold
Project -> Nike reports
Squad -> DcF
Dataset -> Negativos
 
 
###################Bronze Passagem####################################
experian-datahub-passagem-bronze-prod
experian-datahub-passagem-kafkalog-prod
experian-replication-kafka-connector-passagem-prod
 
TAGs:
BU -> EITS
Layer -> Bronze
Project -> Nike reports
Squad -> DcF
Dataset -> Passagem
 
###################Silver Passagem####################################
experian-datahub-passagem-silver-prod
 
TAGs:
BU -> EITS
Layer -> Silver
Project -> Nike reports
Squad -> DcF
Dataset -> Passagem
 
###################Silver Cadastrais####################################
experian-datahub-cadastrais-silver-prod
 
TAGs:
BU -> EITS
Layer -> Silver
Project -> Nike reports
Squad -> DcF
Dataset -> Cadastrais
######################################################################