terraform {
  backend "s3" {
    key = "sa-east-1/iam/roles/BURoleForLno/terraform.tfstate"
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
    "AppID"          = "24051"
    "CostString"     = "1800.BR.134.602018"
    "CreateBy"       = "Terraform"
    "Data_Category"  = "behavioral"
    "Data_Type"      = "pp"
    "Environment"    = "dev"
    "Flow"           = "controlador"
    "map-migrated"   = "d-server-02n52mmgua5hr6"
    "Name"           = "BURoleForLno"
    "Project"        = "datahub"
    "Service"        = "latam_nike"
    "Solution"       = "lno"
    "Squad"          = "comportamental"
    "Sustain"        = "true"
    "wiz_cig"        = "true"
    "version"        = "1"
  }
}

module "BURoleForLno" {
  source = "git::https://code.experian.local/scm/nikesre/terraform-iam-role.git?ref=v1.3.4"

  env                      = local.common_tags.Environment
  name                     = "BURoleForLno"
  assume_role_policy       = file("trust.json")  # Trusted Policy
  instance_profile_created = true
  
  policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM",
    "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    "arn:aws:iam::730335661246:policy/BUPolicyForLno",
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonSQSFullAccess",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole",
    "arn:aws:iam::730335661246:policy/AmazonEMRCleanupPolicy",
    "arn:aws:iam::730335661246:policy/eec-aws-baseline-emr-ec2-role-policy",
    "arn:aws:iam::730335661246:policy/eec-aws-baseline-emr-encryption-policy",
    "arn:aws:iam::730335661246:policy/eec-aws-baseline-emr-role-policy"
  ]
}