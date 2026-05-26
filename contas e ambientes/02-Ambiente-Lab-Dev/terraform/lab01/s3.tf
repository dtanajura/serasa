resource "aws_s3_bucket" "bucketLab" {
  bucket = var.bucketName
  acl    = "private"
  tags = {
    CostString  = var.CostString
    AppID = var.AppID
    Environment = var.Environment
  }
}