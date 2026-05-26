resource "aws_dms_endpoint" "source-endpoint-personValidation" {
  engine_name = "mongodb"
  endpoint_type = "source"
  endpoint_id = "source-migracao-mongodb-customer-relationship-personValidation"
  database_name = "personValidation"
  server_name= "10.97.55.5"
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
    Name = "source-migracao-mongodb-customer-relationship-personValidation"
  }
 }

 resource "aws_dms_endpoint" "target-endpoint-personValidation" {
  engine_name = "docdb"
  endpoint_type = "target"
  endpoint_id = "target-migracao-mongodb-digital-kyc-services-personValidation"
  database_name = "personValidation"
  server_name= "10.99.133.19"
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
    Name = "target-migracao-mongodb-digital-kyc-services-personValidation"
  }
}
