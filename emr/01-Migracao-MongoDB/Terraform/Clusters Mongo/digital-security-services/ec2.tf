resource "aws_instance"  "Mongo-Server-A" {
    ami = "${data.aws_ami.amiCluster.id}"
    associate_public_ip_address=false
    instance_type = var.instanceType
    subnet_id = var.IDsubnetA
    key_name = var.keyName
    vpc_security_group_ids=var.securityGroupsIds
    iam_instance_profile="BURoleForDigitalEC2-SSM"
    tags = {
        Name = "mongodb-digital-security-services-a"
        Description = "BRASA1PDBUES22 (digital-security-services)"
        ResourceOwner = "devsecopsdigitalpaas@br.experian.com"
        ResourceBusinessUnit = "Brazil Digital Paas"
        ResourceCostCenter = "1800.BR.134.502527"
        ResourceName = "brasa1pdbues22.br.experian.eeca1"
        bu = "Digital"
        CWRetentionDays = "30"
        ResourceAppRole = "Db"
        Backup = "False"
        CWAgentInstall = "True"
        Ambiente = "PROD"
    }
}

resource "aws_instance"  "Mongo-Server-B" {
    ami = "${data.aws_ami.amiCluster.id}"
    associate_public_ip_address=false
    instance_type = var.instanceType
    subnet_id = var.IDsubnetB
    key_name = var.keyName
    vpc_security_group_ids=var.securityGroupsIds
    iam_instance_profile="BURoleForDigitalEC2-SSM"
    tags = {
        Name = "mongodb-digital-security-services-b"
        Description = "BRASA1PDBUES23 (digital-security-services)"
        ResourceOwner = "devsecopsdigitalpaas@br.experian.com"
        ResourceBusinessUnit = "Brazil Digital Paas"
        ResourceCostCenter = "1800.BR.134.502527"
        ResourceName = "brasa1pdbues23.br.experian.eeca1"
        bu = "Digital"
        CWRetentionDays = "30"
        ResourceAppRole = "Db"
        Backup = "False"
        CWAgentInstall = "True"
        Ambiente = "PROD"
    }
}

resource "aws_instance"  "Mongo-Server-C" {
    ami = "${data.aws_ami.amiCluster.id}"
    associate_public_ip_address=false
    instance_type = var.instanceType
    subnet_id = var.IDsubnetC
    key_name = var.keyName
    vpc_security_group_ids=var.securityGroupsIds
    iam_instance_profile="BURoleForDigitalEC2-SSM"
    tags = {
        Name = "mongodb-digital-security-services-c"
        Description = "BRASA1PDBUES24 (digital-security-services)"
        ResourceOwner = "devsecopsdigitalpaas@br.experian.com"
        ResourceBusinessUnit = "Brazil Digital Paas"
        ResourceCostCenter = "1800.BR.134.502527"
        ResourceName = "brasa1upbues24.br.experian.eeca1"
        bu = "Digital"
        CWRetentionDays = "30"
        ResourceAppRole = "Db"
        Backup = "False"
        CWAgentInstall = "True"
        Ambiente = "PROD"
    }
}