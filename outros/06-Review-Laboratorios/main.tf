terraform {
  backend s3 {
    bucket = "cockpit-devsecops-states-336544373402"
    key = "aws-eks-serasa/lab02.tfstate"
    region = "sa-east-1"
    profile = "lab02"
  }
}