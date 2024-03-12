# variables.tf
# Conta Nova
variable "accessKey" {
     default = "AKIAUY3NNLEEEDDPBS7J"
}
variable "secretKey" {
     default = "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"
}
# Conta antiga
/*
variable "accessKey" {
     default = "AKIAXFGPJWBLFHYQQ7P7"
}
variable "secretKey" {
     default = "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"
}
*/
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