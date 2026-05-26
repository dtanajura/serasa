#### Ações para correcao de vulnerabilidades de conteineres

#### Passo 01 - ajustar dash do Grafana do Bahia
## Nessa ação vou considerar apenas as contas que estão sob a nossa responsabilidade
## Existem contas que não são nossas

## Instalar a extensão mssql no VS Code
# Abra o Visual Studio Code.
# Vá até a aba de Extensões (ícone de quadrado com 4 pontas na lateral esquerda ou Ctrl+Shift+X).
# Pesquise por: SQL Server (mssql)
# Clique em Instalar na extensão desenvolvida pela Microsoft.

# Dados de conexão
# SPOBRSQLPRD14.br.experian.local:1433
# database DBGovDatabase
# sqldb_nikesre
# aQ86eS5q8@

$crds = kubectl get crds -l chart=istio -o name
foreach ($crd in $crds) {
    kubectl label $crd "app.kubernetes.io/managed-by=Helm" --overwrite
    kubectl annotate $crd "meta.helm.sh/release-name=istio-base" --overwrite
    kubectl annotate $crd "meta.helm.sh/release-namespace=istio-system" --overwrite
}

notepad istiod_values.yaml
notepad istiobase_values.yaml
notepad istioingress_values.yaml

087086536124 - eec-aws-br-nike-ss-sandbox - ok
109804294614 - eec-aws-us-eits-positivo-dev - ok
146737708860 - eec-aws-br-ds-dataservices-stage - ok
187739130313 - eec-aws-br-nike-architecture-sandbox - ok
300374333803 - eec-aws-us-eits-negativo-dev - ok
306716481758 - eec-aws-br-nike-ssrm-dev - ok
415071355886 - eec-aws-br-eits-datahub-prod - pendente (1.23)
530914589075 - eec-aws-br-ds-dataservices-dev - ok
564593125549 - eec-aws-br-nike-corporate-prod - pendente (1.17 e 1.23)
662860092544 - eec-aws-br-ds-dataservices-prod - pendente (1.23)
730335661246 - eec-aws-br-eits-datahub-dev - ok
877001948254 - eec-aws-br-nike-sales-prod - sales-eks-01-prod - pendente (1.18 e 1.23)
877001948254 - eec-aws-br-nike-sales-prod - sales-eks-01-uat - ok


