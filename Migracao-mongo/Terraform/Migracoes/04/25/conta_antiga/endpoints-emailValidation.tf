resource "aws_dms_endpoint" "source-endpoint-emailValidation" {
  engine_name = "mongodb"
  endpoint_type = "source"
  endpoint_id = "source-migracao-mongodb-customer-relationship-emailValidation"
  database_name = "emailValidation"
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
    Name = "source-migracao-mongodb-customer-relationship-emailValidation"
  }
 }

 resource "aws_dms_endpoint" "target-endpoint-emailValidation" {
  engine_name = "docdb"
  endpoint_type = "target"
  endpoint_id = "destination-migracao-mongodb-digital-kyc-services-emailValidation"
  database_name = "emailValidation"
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
    Name = "destination-migracao-mongodb-digital-kyc-services-emailValidation"
  }
}
