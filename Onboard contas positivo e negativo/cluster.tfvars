assume_role_arn         = "arn:aws:iam::300374333803:role/BURoleForDevSecOpsCockpitService"
region                  = "us-east-1"
env                     = "dev"
eks_cluster_name        = "negativo-dev"
eks_cluster_version     = "1.32"
eks_ami_id              = "latest"
vpc_id                  = "vpc-0c097736e5bf857f5"
subnets                 = "subnet-03fdb69de03ec032c,subnet-05df4112c8597e669,subnet-09a45adfd919bfc1b"
use_proxy               = "auto"
eks_storage_size        = "50"
eks_storage_iops        = "3000"
eks_storage_throughtput = "125"
efs_enabled             = "true"
efs_storageclass_mode   = "elastic"
karpenter               = "disabled"
nodegroup_names_prefix  = ""
dockerhub_cache_prefix  = ""
project_name            = "negativos_privados"
resource_business_unit  = "EITS"
resource_owner          = "Datahub_Squad_NegativosPrivados@experian.com"
resource_name           = "negativo-dev"
resource_app_id         = "9339"
resource_cost_center    = "1800.BR.134.602018"
ad_domain               = "br.experian.local"
service_request         = "RITM4201516"
repo_version            = "v1.10-100-gf37b0a9"

# Metrics Server
metrics_server_replicas            = 1
metrics_server_hostNetwork_enabled = true
metrics_server_containerPort       = 4443

# Istio
istio_ingress_enabled      = true
istio_ingress_force_update = false
istio_ingress_annotation = {
  "service.beta.kubernetes.io/aws-load-balancer-ssl-cert"               = "arn:aws:acm:us-east-1:300374333803:certificate/f38e630e-23f4-4bba-8c90-08ae485b4a30"
  "service.beta.kubernetes.io/aws-load-balancer-backend-protocol"       = "http"
  "service.beta.kubernetes.io/aws-load-balancer-type"                   = "nlb"
  "service.beta.kubernetes.io/aws-load-balancer-ssl-ports"              = "443"
  "service.beta.kubernetes.io/aws-load-balancer-internal"               = true
  "service.beta.kubernetes.io/aws-load-balancer-ssl-negotiation-policy" = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  "service.beta.kubernetes.io/aws-load-balancer-proxy-protocol"         = "*"
  "service.beta.kubernetes.io/aws-load-balancer-access-log-enabled"     = true
  "service.beta.kubernetes.io/aws-load-balancer-access-log-s3-bucket-prefix"        = "logs-istio-nlb"
  "service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled"  = true
  "service.beta.kubernetes.io/aws-load-balancer-subnets"                            = "auto_private"
}

istio_ingress_ports = [
  {
    "name"       = "status-port"
    "port"       = "15021"
    "protocol"   = "TCP"
    "targetPort" = "15021"
  },
  {
    "name"       = "http2"
    "port"       = "80"
    "protocol"   = "TCP"
    "targetPort" = "80"
  },
  {
    "name"       = "https"
    "port"       = "443"
    "protocol"   = "TCP"
    "targetPort" = "8080"
  }
]
istio_ingress_loadBalancerSourceRanges = [
  "10.0.0.0/8"
]

# External DNS
external_dns_provider = "aws"
external_dns_source = [
  "ingress",
  "istio-gateway",
  "istio-virtualservice",
]
external_dns_domain_filters = [
  "dev-us-negativo.br.experian.eeca"
]
external_dns_logLevel = "debug"
external_dns_extra_args = [
  "--aws-zone-type=private",
]

addon_kubeproxy_version = ""
addon_coredns_version = ""
addon_vpccni_version = ""
addon_ebscsi_version = ""

# Nodes Max Size
eks_managed_node_infra_max_size  = "3"
eks_managed_node_small_max_size  = "0"
eks_managed_node_medium_max_size = "0"
eks_managed_node_larger_max_size = "3"
eks_managed_node_spot_max_size   = "0"

eks_managed_node_infra_instance_type  = "c6i.2xlarge"
eks_managed_node_small_instance_type  = "t3.large"
eks_managed_node_medium_instance_type = "t3.xlarge"
eks_managed_node_large_instance_type  = "t3.2xlarge"
eks_managed_node_spot_instance_type   = "t3.xlarge"

# Optional components
install_jaeger_istio = false
install_vpa = false
install_goldilocks = false
install_loki_stack = false
install_kiali = false
