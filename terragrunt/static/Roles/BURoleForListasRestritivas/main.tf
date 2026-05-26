terraform {
  backend "s3" {
    key = "sa-east-1/iam/roles/BURoleForListasRestritivas/terraform.tfstate"
  }
}

provider "aws" {
  region = "sa-east-1"
  profile = "datahubdev"
  default_tags {
    tags = local.common_tags
  }
}
locals {
  common_tags = {
    "Asset_Category" = "Development"
    "AppID"          = "25135"
    "CostString"     = "1800.BR.134.602018"
    "CreateBy"       = "Terraform"
    "Data_Category"  = "N/A"
    "Data_Type"      = "N/A"
    "Environment"    = "dev"
    "Flow"           = "operador"
    "map-migrated"   = "d-server-02n52mmgua5hr6"
    "Name"           = "BURoleForListasRestritivas"
    "Project"        = "datahub"
    "Service"        = "latam_nike"
    "Solution"       = "listas_restritivas"
    "Squad"          = "cadastral"
    "Sustain"        = "true"
    "wiz_cig"        = "true" 
  }
}

module "BURoleForListasRestritivas" {
  source = "git::https://code.experian.local/scm/nikesre/terraform-iam-role.git?ref=v1.3.1"

  env                = local.common_tags.Environment
  name               = "BURoleForListasRestritivas"
  assume_role_policy = file("trust.json")  # Trusted Policy
  
  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonSQSFullAccess",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole",
    "arn:aws:iam::730335661246:policy/BUPolicyForListasRestritivas"
  ]
}