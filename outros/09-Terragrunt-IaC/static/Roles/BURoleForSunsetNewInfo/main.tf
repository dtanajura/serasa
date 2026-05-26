terraform {
  backend "s3" {
    key = "sa-east-1/iam/roles/BURoleForSunsetNewInfo/terraform.tfstate"
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
    "AppID" = "23008"
    "CostString" = "1800.BR.134.602018"
    "CreateBy" = "Terraform"
    "Data_Category" = "N/A"
    "Data_Type" = "N/A"
    "Environment" = "dev"
    "Flow" = "controlador"
    "map-migrated" = "d-server-02n52mmgua5hr6"
    "Name" = "BURoleForSunsetNewInfo"
    "Project" = "datahub"
    "Service" = "latam_nike"
    "Solution" = "sunsetnewinfo"
    "Squad" = "sunsetnewinfo"
    "Sustain" = "false"
    "wiz_cig" = "true"
  }
}

module "BURoleForSunsetNewInfo" {
  source = "git::https://code.experian.local/scm/nikesre/terraform-iam-role.git?ref=v1.3.1"

  env = local.common_tags.Environment
  name = "BURoleForSunsetNewInfo"
  assume_role_policy = file("trust.json")
  # Trusted Policy

  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonSQSFullAccess",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole",
    "arn:aws:iam::730335661246:policy/BUPolicyForSunsetNewInfo"
  ]
}
