resource "aws_dms_endpoint" "source-migracao-mongodb-digital-persona-video-loan-sendgrid" {
  engine_name = "mongodb"
  endpoint_type = "source"
  endpoint_id = "source-migracao-mongodb-digital-persona-video-loan-sendgrid"
  database_name = "sendgrid"
  server_name= "10.97.55.104"
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
    Name = "source-migracao-mongodb-digital-persona-video-loan-sendgrid"
  }
 }

 resource "aws_dms_endpoint" "destination-migracao-mongodb-digital-services-sendgrid" {
  engine_name = "docdb"
  endpoint_type = "target"
  endpoint_id = "destination-migracao-mongodb-digital-services-sendgrid"
  database_name = "sendgrid"
  server_name= "10.99.133.11"
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
    Name = "source-migracao-mongodb-digital-services-sendgrid"
  }
#  certificate_arn = "arn:aws:kms:sa-east-1:492208500822:key/a64924db-7648-4ce2-92b2-295ab2a50ab2"
# kms_key_arn                 = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
#  extra_connection_attributes = ""

 }