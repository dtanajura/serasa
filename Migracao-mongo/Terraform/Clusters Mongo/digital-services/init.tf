provider "aws" {
#  version = "~> 2.0"
  access_key = var.accessKey 
  secret_key = var.secretKey 
  region     = var.region
}


data "aws_ami" "amiCluster" {
  most_recent = true
  filter {
    name = "name"
    values = [var.amiName]
  }
}

output "AmiIDNumber" {
  value = "${data.aws_ami.amiCluster.id}"
}