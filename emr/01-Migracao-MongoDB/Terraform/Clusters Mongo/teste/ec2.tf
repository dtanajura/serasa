resource "aws_instance" "teste-A" {
  # .\terraform.exe  import "aws_instance.Mongo-Server-A" i-0a086eb593d178176
    ami = "${data.aws_ami.amiCluster.id}"
    associate_public_ip_address=false
    instance_type = var.instanceType
    subnet_id = var.IDsubnetA
    key_name = var.keyName
    vpc_security_group_ids=var.securityGroupsIds
    iam_instance_profile="BURoleForDigitalEC2-SSM"
    tags = {
        Name = "teste-a"
        Description = "BRASA1UDBUES07 (digital-uat)"
        ResourceOwner = "devsecopsdigitalpaas@br.experian.com"
        ResourceBusinessUnit = "Brazil Digital Paas"
        ResourceCostCenter = "1800.BR.134.502527"
        ResourceName = "brasa1udbues10.br.experian.eeca1"
        bu = "Digital"
        CWRetentionDays = "30"
        ResourceAppRole = "Db"
        Backup = "False"
        CWAgentInstall = "True"
        Ambiente = "UAT"
    }
}
/*
resource "aws_instance" "Mongo-Server-B" {
  # .\terraform.exe  import "aws_instance.Mongo-Server-B" i-033b9946cb711499b
    ami = "ami-0b54d97016015afc1"
    associate_public_ip_address=false
    instance_type = var.instanceType
    subnet_id = var.IDsubnetB
    key_name = var.keyName
    vpc_security_group_ids=var.securityGroupsIds
    iam_instance_profile="BURoleForDigitalEC2-SSM"
    tags = {
        Name = "mongodb-digital-uat-b"
        Description = "BRASA1UDBUES08 (digital-uat)"
        ResourceOwner = "devsecopsdigitalpaas@br.experian.com"
        ResourceBusinessUnit = "Brazil Digital Paas"
        ResourceCostCenter = "1800.BR.134.502527"
        ResourceName = "brasa1udbues08.br.experian.eeca1"
        bu = "Digital"
        CWRetentionDays = "30"
        ResourceAppRole = "Db"
        Backup = "False"
        CWAgentInstall = "True"
        Ambiente = "UAT"
    }
}

resource "aws_instance" "Mongo-Server-C" {
  # .\terraform.exe  import "aws_instance.Mongo-Server-C" i-0a6c284bc46b400a2
    ami = "ami-0b54d97016015afc1"
    associate_public_ip_address=false
    instance_type = var.instanceType
    subnet_id = var.IDsubnetC
    key_name = var.keyName
    vpc_security_group_ids=var.securityGroupsIds
    iam_instance_profile="BURoleForDigitalEC2-SSM"
    tags = {
        Name = "mongodb-digital-uat-c"
        Description = "BRASA1UDBUES09 (digital-uat)"
        ResourceOwner = "devsecopsdigitalpaas@br.experian.com"
        ResourceBusinessUnit = "Brazil Digital Paas"
        ResourceCostCenter = "1800.BR.134.502527"
        ResourceName = "brasa1udbues09.br.experian.eeca1"
        bu = "Digital"
        CWRetentionDays = "30"
        ResourceAppRole = "Db"
        Backup = "False"
        CWAgentInstall = "True"
        Ambiente = "UAT"
    }
}
*/