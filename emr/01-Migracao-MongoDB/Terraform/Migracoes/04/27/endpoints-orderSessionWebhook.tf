resource "aws_dms_endpoint" "source-endpoint-orderSessionWebhook" {
  engine_name = "mongodb"
  endpoint_type = "source"
  endpoint_id = "source-migracao-mongodb-digital-commerce-services-orderSessionWebhook"
  database_name = "orderSessionWebhook"
  server_name= "10.97.55.105"
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
    Name = "source-migracao-mongodb-digital-commerce-services-orderSessionWebhook"
  }
 }

 resource "aws_dms_endpoint" "target-endpoint-orderSessionWebhook" {
  engine_name = "docdb"
  endpoint_type = "target"
  endpoint_id = "target-migracao-mongodb-digital-commerce-services-orderSessionWebhook"
  database_name = "orderSessionWebhook"
  server_name= "10.99.133.26"
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
    Name = "target-migracao-mongodb-digital-commerce-services-orderSessionWebhook"
  }
}