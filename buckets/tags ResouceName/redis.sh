# Defina o perfil
$profile = "dsprod"

# Lista de grupos de replicação Redis
$replicationGroups = @(
    "airflow-datahub-prod",
    "ds-elasticache-redis-prod-redis",
    "ds-innovation-elasticache-redis-prod",
    "negativescache-pf-redis",
    "negativescache-pj-redis",
    "positivo-opt-mongo-redis",
    "summarycache-pf-v2-redis",
    "summarycache-pj-v2-redis",
    "v3-apis"
)

# Adicionar tag ResourceName para cada grupo de replicação
foreach ($group in $replicationGroups) {
    $arn = "arn:aws:elasticache:sa-east-1:662860092544:replicationgroup:$group"
    aws elasticache add-tags-to-resource --profile $profile --resource-name $arn --tags Key=ResourceName,Value=$group
}

aws elasticache add-tags-to-resource --profile dsprod --resource-name arn:aws:elasticache:sa-east-1:662860092544:cluster:airflow-datahub-prod-001 --tags Key=ResourceName,Value=airflow-datahub-prod
aws elasticache add-tags-to-resource --profile dsprod --resource-name arn:aws:elasticache:sa-east-1:662860092544:cluster:airflow-datahub-prod-002 --tags Key=ResourceName,Value=airflow-datahub-prod
aws elasticache add-tags-to-resource --profile dsprod --resource-name arn:aws:elasticache:sa-east-1:662860092544:cluster:ds-elasticache-redis-prod-redis-001 --tags Key=ResourceName,Value=ds-elasticache-redis-prod-redis
aws elasticache add-tags-to-resource --profile dsprod --resource-name arn:aws:elasticache:sa-east-1:662860092544:cluster:ds-elasticache-redis-prod-redis-002 --tags Key=ResourceName,Value=ds-elasticache-redis-prod-redis
aws elasticache add-tags-to-resource --profile dsprod --resource-name arn:aws:elasticache:sa-east-1:662860092544:cluster:ds-innovation-elasticache-redis-prod-001 --tags Key=ResourceName,Value=ds-innovation-elasticache-redis-prod
aws elasticache add-tags-to-resource --profile dsprod --resource-name arn:aws:elasticache:sa-east-1:662860092544:cluster:ds-innovation-elasticache-redis-prod-002 --tags Key=ResourceName,Value=ds-innovation-elasticache-redis-prod
aws elasticache add-tags-to-resource --profile dsprod --resource-name arn:aws:elasticache:sa-east-1:662860092544:cluster:ds-innovation-elasticache-redis-prod-003 --tags Key=ResourceName,Value=ds-innovation-elasticache-redis-prod
aws elasticache add-tags-to-resource --profile dsprod --resource-name arn:aws:elasticache:sa-east-1:662860092544:cluster:negativescache-pf-redis-001 --tags Key=ResourceName,Value=negativescache-pf-redis
aws elasticache add-tags-to-resource --profile dsprod --resource-name arn:aws:elasticache:sa-east-1:662860092544:cluster:negativescache-pf-redis-002 --tags Key=ResourceName,Value=negativescache-pf-redis
aws elasticache add-tags-to-resource --profile dsprod --resource-name arn:aws:elasticache:sa-east-1:662860092544:cluster:negativescache-pj-redis-001 --tags Key=ResourceName,Value=negativescache-pj-redis
aws elasticache add-tags-to-resource --profile dsprod --resource-name arn:aws:elasticache:sa-east-1:662860092544:cluster:negativescache-pj-redis-002 --tags Key=ResourceName,Value=negativescache-pj-redis
aws elasticache add-tags-to-resource --profile dsprod --resource-name arn:aws:elasticache:sa-east-1:662860092544:cluster:positivo-opt-mongo-redis-001 --tags Key=ResourceName,Value=positivo-opt-mongo-redis
aws elasticache add-tags-to-resource --profile dsprod --resource-name arn:aws:elasticache:sa-east-1:662860092544:cluster:positivo-opt-mongo-redis-002 --tags Key=ResourceName,Value=positivo-opt-mongo-redis
aws elasticache add-tags-to-resource --profile dsprod --resource-name arn:aws:elasticache:sa-east-1:662860092544:cluster:summarycache-pf-v2-redis-001 --tags Key=ResourceName,Value=summarycache-pf-v2-redis
aws elasticache add-tags-to-resource --profile dsprod --resource-name arn:aws:elasticache:sa-east-1:662860092544:cluster:summarycache-pf-v2-redis-002 --tags Key=ResourceName,Value=summarycache-pf-v2-redis
aws elasticache add-tags-to-resource --profile dsprod --resource-name arn:aws:elasticache:sa-east-1:662860092544:cluster:summarycache-pj-v2-redis-001 --tags Key=ResourceName,Value=summarycache-pj-v2-redis
aws elasticache add-tags-to-resource --profile dsprod --resource-name arn:aws:elasticache:sa-east-1:662860092544:cluster:summarycache-pj-v2-redis-002 --tags Key=ResourceName,Value=summarycache-pj-v2-redis
aws elasticache add-tags-to-resource --profile dsprod --resource-name arn:aws:elasticache:sa-east-1:662860092544:cluster:v3-apis-001 --tags Key=ResourceName,Value=v3-apis



# Outras Tags


 
 

Adicionar tags no REDIS:
# REDIS PJ:
# summarycache-pj-redis
# summarycache-pj-v2-redis
 
# TAGs:
# BU -> EITS
# Layer -> Gold
# Project -> Nike reports
# Squad -> DcF
# Dataset -> Negativos
 
# REDIS PJ
# Grupos de Replicação
# aws elasticache add-tags-to-resource --profile dsprod --resource-name arn:aws:elasticache:sa-east-1:662860092544:replicationgroup:summarycache-pj-redis --tags Key=BU,Value=EITS Key=Layer,Value=Gold Key=Project,Value="Nike reports" Key=Squad,Value=DcF Key=Dataset,Value=Negativos
aws elasticache add-tags-to-resource --profile dsprod --resource-name arn:aws:elasticache:sa-east-1:662860092544:replicationgroup:summarycache-pj-v2-redis --tags Key=BU,Value=EITS Key=Layer,Value=Gold Key=Project,Value="Nike reports" Key=Squad,Value=DcF Key=Dataset,Value=Negativos
# Clusters
aws elasticache add-tags-to-resource --profile dsprod --resource-name arn:aws:elasticache:sa-east-1:662860092544:cluster:summarycache-pj-v2-redis-001 --tags Key=BU,Value=EITS Key=Layer,Value=Gold Key=Project,Value="Nike reports" Key=Squad,Value=DcF Key=Dataset,Value=Negativos
aws elasticache add-tags-to-resource --profile dsprod --resource-name arn:aws:elasticache:sa-east-1:662860092544:cluster:summarycache-pj-v2-redis-002 --tags Key=BU,Value=EITS Key=Layer,Value=Gold Key=Project,Value="Nike reports" Key=Squad,Value=DcF Key=Dataset,Value=Negativos

# REDIS PF
# summarycache-pf-redis
# summarycache-pf-v2-redis
# BU -> EITS
# Layer -> Gold
# Project -> Nike reports
# Squad -> DcF
# Dataset -> Negativos

# REDIS PF
# Grupos de Replicação
# aws elasticache add-tags-to-resource --profile dsprod --resource-name arn:aws:elasticache:sa-east-1:662860092544:replicationgroup:summarycache-pf-redis --tags Key=BU,Value=EITS Key=Layer,Value=Gold Key=Project,Value="Nike reports" Key=Squad,Value=DcF Key=Dataset,Value=Negativos
aws elasticache add-tags-to-resource --profile dsprod --resource-name arn:aws:elasticache:sa-east-1:662860092544:replicationgroup:summarycache-pf-v2-redis --tags Key=BU,Value=EITS Key=Layer,Value=Gold Key=Project,Value="Nike reports" Key=Squad,Value=DcF Key=Dataset,Value=Negativos
# Clusters
aws elasticache add-tags-to-resource --profile dsprod --resource-name arn:aws:elasticache:sa-east-1:662860092544:cluster:summarycache-pf-v2-redis-001 --tags Key=BU,Value=EITS Key=Layer,Value=Gold Key=Project,Value="Nike reports" Key=Squad,Value=DcF Key=Dataset,Value=Negativos
aws elasticache add-tags-to-resource --profile dsprod --resource-name arn:aws:elasticache:sa-east-1:662860092544:cluster:summarycache-pf-v2-redis-002 --tags Key=BU,Value=EITS Key=Layer,Value=Gold Key=Project,Value="Nike reports" Key=Squad,Value=DcF Key=Dataset,Value=Negativos

