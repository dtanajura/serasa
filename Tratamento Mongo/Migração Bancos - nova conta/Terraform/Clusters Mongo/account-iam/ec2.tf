resource "aws_instance"  "Mongo-Server-A" {
    ami = "${data.aws_ami.amiCluster.id}"
    associate_public_ip_address=false
    instance_type = var.instanceType
    subnet_id = var.IDsubnetA
    key_name = var.keyName
    vpc_security_group_ids=var.securityGroupsIds
    iam_instance_profile="BURoleForDigitalEC2-SSM"
    tags = {
        Name = "mongodb-account-iam-a"
        Description = "BRASA1PDBUES16 (account-iam)"
        ResourceOwner = "devsecopsdigitalpaas@br.experian.com"
        ResourceBusinessUnit = "Brazil Digital Paas"
        ResourceCostCenter = "1800.BR.134.502527"
        ResourceName = "brasa1pdbues16.br.experian.eeca1"
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
        Name = "mongodb-account-iam-b"
        Description = "BRASA1PDBUES17 (account-iam)"
        ResourceOwner = "devsecopsdigitalpaas@br.experian.com"
        ResourceBusinessUnit = "Brazil Digital Paas"
        ResourceCostCenter = "1800.BR.134.502527"
        ResourceName = "brasa1pdbues17.br.experian.eeca1"
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
        Name = "mongodb-account-iam-c"
        Description = "BRASA1PDBUES18 (account-iam)"
        ResourceOwner = "devsecopsdigitalpaas@br.experian.com"
        ResourceBusinessUnit = "Brazil Digital Paas"
        ResourceCostCenter = "1800.BR.134.502527"
        ResourceName = "brasa1upbues18.br.experian.eeca1"
        bu = "Digital"
        CWRetentionDays = "30"
        ResourceAppRole = "Db"
        Backup = "False"
        CWAgentInstall = "True"
        Ambiente = "PROD"
    }
}