resource "aws_instance"  "Mongo-Server-A" {
    ami = "${data.aws_ami.amiCluster.id}"
    associate_public_ip_address=false
    instance_type = var.instanceType
    subnet_id = var.IDsubnetA
    key_name = var.keyName
    vpc_security_group_ids=var.securityGroupsIds
    iam_instance_profile="BURoleForDigitalEC2-SSM"
    tags = {
        Name = "mongodb-digital-kyc-services-a"
        Description = "BRASA1PDBUES19 (digital-kyc-services)"
        ResourceOwner = "devsecopsdigitalpaas@br.experian.com"
        ResourceBusinessUnit = "Brazil Digital Paas"
        ResourceCostCenter = "1800.BR.134.502527"
        ResourceName = "brasa1pdbues19.br.experian.eeca1"
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
        Name = "mongodb-digital-kyc-services-b"
        Description = "BRASA1PDBUES20 (digital-kyc-services)"
        ResourceOwner = "devsecopsdigitalpaas@br.experian.com"
        ResourceBusinessUnit = "Brazil Digital Paas"
        ResourceCostCenter = "1800.BR.134.502527"
        ResourceName = "brasa1pdbues20.br.experian.eeca1"
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
        Name = "mongodb-digital-kyc-services-c"
        Description = "BRASA1PDBUES21 (digital-kyc-services)"
        ResourceOwner = "devsecopsdigitalpaas@br.experian.com"
        ResourceBusinessUnit = "Brazil Digital Paas"
        ResourceCostCenter = "1800.BR.134.502527"
        ResourceName = "brasa1upbues21.br.experian.eeca1"
        bu = "Digital"
        CWRetentionDays = "30"
        ResourceAppRole = "Db"
        Backup = "False"
        CWAgentInstall = "True"
        Ambiente = "PROD"
    }
}