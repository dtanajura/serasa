resource "aws_dms_endpoint" "source-endpoint-crypto" {
  engine_name = "mongodb"
  endpoint_type = "source"
  endpoint_id = "source-migracao-mongodb-digital-services-crypto-crypto"
  database_name = "crypto"
  server_name= "10.97.55.126"
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
    Name = "source-migracao-mongodb-digital-services-crypto-crypto"
  }
 }

 resource "aws_dms_endpoint" "target-endpoint-crypto" {
  engine_name = "docdb"
  endpoint_type = "target"
  endpoint_id = "target-migracao-mongodb-digital-security-services-crypto"
  database_name = "crypto"
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
    Name = "target-migracao-mongodb-digital-security-services-crypto"
  }
}
