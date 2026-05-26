terraform {
  backend "s3" {
    key = "sa-east-1/emrstudio/dataexplore/terraform.tfstate"
  }
}

provider "aws" {
  region = "sa-east-1"
  profile = "devhub-legada-sandbox"

  default_tags {
    tags = local.common_tags
  }
}

locals {
  common_tags = {
    "Environment" = "sbx"
    "CreateBy"    = "Terraform"
    "Asset_Category" = "Embbeded"
    "Data_Type" = "NA"
    "Data_Category" = "NA"
    "CostString" = "1800.BR.XXX.YYYYYYY"
    "AppID" = "20XXX"
  }
  name="data_explore"
  
}

module "bucket_s3" {
  source = "git::ssh://git@code.experian.local/nikesre/terraform-s3.git?ref=v1.2.8"

  env         = local.common_tags.Environment
  bucket_name = "teste-01-davi"
}

module "emr_studio_iam" {
  source                             = "git::https://code.experian.local/scm/datastrate/terraform-modules.git//emr-studio?ref=emr-studio-v0.0.11"
  name                               = "${local.name}-iam"
  auth_mode                          = "IAM"
  default_s3_location                = "s3://${module.bucket_s3.s3_bucket_arn}/workspace"
  s3_emr_cluster_logs                = module.bucket_s3.s3_bucket_arn
  tags                               = local.common_tags
  security_group_name                = var.project_name
  service_role_name                  = "BURoleForEMRStudioServiceRole"
  service_role_policy_name           = "BUPolicyForEMRStudioServiceRole"
  project_name                       = var.project_name
  team                               = var.team
  buckets_name_allow_emr_studio_role = var.buckets_name_allow_emr_studio_role
  buckets_name_deny_emr_studio_role  = var.buckets_name_deny_emr_studio_role
  team_list                          = var.team_list
  maximum_capacity_units             = var.maximum_capacity_units
  maximum_core_capacity_units        = var.maximum_core_capacity_units
  maximum_ondemand_capacity_units    = var.maximum_ondemand_capacity_units
  minimum_capacity_units             = var.minimum_capacity_units
  allowed_applications               = var.allowed_applications
  emr_cluster_configurations         = var.emr_cluster_configurations
  allowed_instance_types             = var.allowed_instance_types
  bootstrap_script_path              = var.bootstrap_script_path != "" ? "${path.cwd}/${var.bootstrap_script_path}" : ""
  #Role that will be used for Data Engineers needs to create AD Group to be accessed
  user_role_name                     = replace("BURoleForDataEngineer${var.team}", "_", "")
  user_role_policy_name              = "BUPolicyForEMRStudioUserRole"
  service_role_tags                  = var.team != "" ? { Team = "${var.team}" } : {}
  gearr_id                           = var.gearr_id
  cluster_role_name                  = aws_iam_role.BURoleForEMR.name
  cost_string                        = var.cost_string
}
