# variables.tf
variable "accessKey" {
     default = ""
}
variable "secretKey" {
     default = ""
}
variable "amiName" {
    default = "ami-base-mongo-rhel8-2023-04-05"
}
variable "region" {
     default = "sa-east-1"
}
variable "keyName" {
    default = "digital-2"
}
variable "instanceType" {
    default = "t3.xlarge"
}
variable "securityGroupsIds" {
  type    = list(string)
  default = ["sg-0ef01e3210d87dffb","sg-0d2655c4bf3a7bb14"]
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