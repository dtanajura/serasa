terraform {
  backend "s3" {
    key = "sa-east-1/iam/roles/BURoleForUfrn/terraform.tfstate"
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
    "AppID"          = "26035"
    "CostString"     = "1800.BR.134.602018"
    "CreateBy"       = "Terraform"
    "Data_Category"  = "behavioral"
    "Data_Type"      = "pp"
    "Environment"    = "dev"
    "Flow"           = "controlador"
    "map-migrated"   = "d-server-02n52mmgua5hr6"
    "Name"           = "BURoleForUfrn"
    "Project"        = "datahub"
    "Service"        = "latam_nike"
    "Solution"       = "ufrn"
    "Squad"          = "renda"
    "Sustain"        = "false"
    "wiz_cig"        = "true"
    "Version"        = "1.0.5"
  }
}

module "BURoleForUfrn" {
  
  source = "git::https://code.experian.local/scm/nikesre/terraform-iam-role.git?ref=v1.3.4"
  env                = local.common_tags.Environment
  name               = "BURoleForUfrn"
  assume_role_policy = file("trust.json")  # Trusted Policy
  instance_profile_created = true
  
  policy_arns = [
    "arn:aws:iam::730335661246:policy/BUPolicyForUfrn",
    "arn:aws:iam::730335661246:policy/BUPolicyForRendaDefaultEc2",
    "arn:aws:iam::730335661246:policy/BUPolicyForRendaDefaultSsm",
    "arn:aws:iam::aws:policy/AmazonSQSFullAccess",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]
}