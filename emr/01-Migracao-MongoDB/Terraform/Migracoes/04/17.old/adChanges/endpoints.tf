resource "aws_dms_endpoint" "source-migracao-mongodb-mongodb-account-iam-adChanges" {
  engine_name = "mongodb"
  endpoint_type = "source"
  endpoint_id = "source-migracao-mongodb-mongodb-account-iam-adChanges"
  database_name = "adChanges"
  server_name= "10.97.55.13"
  username = "migracao-database"
  password = "123Troc@r"
  port = 27017
  ssl_mode = "none"
  mongodb_settings {
    auth_mechanism="default"
    auth_source="admin"
    auth_type="password"
  }

  tags = {
    Name = "source-migracao-mongodb-mongodb-account-iam-adChanges"
  }
 }

 resource "aws_dms_endpoint" "destination-migracao-mongodb-digital-security-services-adChanges" {
  engine_name = "docdb"
  endpoint_type = "target"
  endpoint_id = "destination-migracao-mongodb-digital-security-services-adChanges"
  database_name = "adChanges"
  server_name= "10.99.133.10"
  username = "migracao-database"
  password = "123Troc@r"
  port = 27017
  ssl_mode = "none"
  mongodb_settings {
    auth_mechanism="default"
    auth_source="admin"
    auth_type="password"
  }

  tags = {
    Name = "destination-migracao-mongodb-digital-security-services-adChanges"
  }
#  certificate_arn = "arn:aws:kms:sa-east-1:492208500822:key/a64924db-7648-4ce2-92b2-295ab2a50ab2"
# kms_key_arn                 = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
#  extra_connection_attributes = ""

 }