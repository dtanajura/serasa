terraform {
  backend "s3" {
    key = "sa-east-1/iam/roles/BURoleForDatahubOperation/terraform.tfstate"
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
    "AppID" = "N/A"
    "CostString" = "1800.BR.134.602018"
    "CreateBy" = "Terraform"
    "Data_Category" = "N/A"
    "Data_Type" = "N/A"
    "Environment" = "dev"
    "map-migrated" = "d-server-02n52mmgua5hr6"
    "Project" = "nike"
    "Service" = "latam_nike"
    "wiz_cig" = "true"
  }
}

module "BURoleForDatahubOperation" {
  source = "git::https://code.experian.local/scm/nikesre/terraform-iam-role.git?ref=v1.3.3"

  env = local.common_tags.Environment
  name = "BURoleForDatahubOperation"
  assume_role_policy = file("role.json")
  policy_arns = [
    "arn:aws:iam::730335661246:policy/BUPolicyForDatahubOperation",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/AmazonSSMFullAccess"]
}
