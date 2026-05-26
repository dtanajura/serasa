terraform {
  backend "s3" {
    key = "sa-east-1/iam/roles/BURoleForContatos/terraform.tfstate"
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
    "AppID"          = "23008"
    "CostString"     = "1800.BR.134.602018"
    "CreateBy"       = "Terraform"
    "Data_Category"  = "N/A"
    "Data_Type"      = "N/A"
    "Environment"    = "dev"
    "Flow"           = "operador"
    "map-migrated"   = "d-server-02n52mmgua5hr6"
    "Name"           = "BURoleForContatos"
    "Project"        = "datahub"
    "Service"        = "latam_nike"
    "Solution"       = "contatos"
    "Squad"          = "cadastral"
    "Sustain"        = "true"
    "wiz_cig"        = "true"
  }
}

module "BURoleForContatos" {
  source = "git::https://code.experian.local/scm/nikesre/terraform-iam-role.git?ref=v1.3.1"

  env                = local.common_tags.Environment
  name               = "BURoleForContatos"
  assume_role_policy = file("trust.json")  # Trusted Policy

  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSQSFullAccess",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole",
    "arn:aws:iam::730335661246:policy/BUPolicyForContatos",
    "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM",
    "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    "arn:aws:iam::730335661246:policy/eec-aws-baseline-emr-ec2-role-policy",
    "arn:aws:iam::730335661246:policy/eec-aws-baseline-emr-encryption-policy",
    "arn:aws:iam::730335661246:policy/eec-aws-baseline-emr-role-policy"
  ]
}
