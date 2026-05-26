resource "aws_s3_bucket" "rep-digital-paas" {
  bucket = "repositorio-digital-paas"

  tags = {
    Name        = "Repositorio S3 Digital PaaS - time SRE"
    Environment = "Dev"
  }
}
