# variables.tf
variable "accessKey" {
     default = ""
}
variable "secretKey" {
     default = ""
}
variable "bucketName" {
  default =  "nomeBucketDevHubLab01"
}
variable "CostString" {
  default = "1800.BR.134.607500"
} 
variable "AppID" {
  default = "20274" #dev-hub-portal
}
variable "Environment" {
  default = "sbx"
}

variable "region" {
     default = "sa-east-1"
}
variable "IDsubnetA" {
  default = "subnet-0b98c95db550ce9d9"
}
variable "IDsubnetB" {
  default = "subnet-0bc91637c41307d1e"
}
variable "IDsubnetC" {
  default = "subnet-033160ee36b4f778f"
}
variable "tamanhoDisco" {
  default = "10"
}

variable "securityGroupsIds" {
  type    = list(string)
  default = ["sg-02a902d89ac8c34e5"]
}
variable "subnetGroupId" {
  default = "sng-teste-migracao"
}
variable "instanceSize" {
  default = "dms.c5.4xlarge" #"dms.t3.medium"
}
