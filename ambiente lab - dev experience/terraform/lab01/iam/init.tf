provider "aws" {
#  version = "~> 2.0"
  access_key = var.accessKey 
  secret_key = var.secretKey 
  region     = var.region
}

