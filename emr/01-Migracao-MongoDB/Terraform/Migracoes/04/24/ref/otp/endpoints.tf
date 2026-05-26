resource "aws_dms_endpoint" "source-endpoint-otp" {
  engine_name = "mongodb"
  endpoint_type = "source"
  endpoint_id = "source-migracao-mongodb-account-iam-services-otp"
  database_name = "otp"
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
    Name = "source-migracao-mongodb-digital-commerce-services-otp"
  }
}

resource "aws_dms_endpoint" "target-endpoint-otp" {
  engine_name = "docdb"
  endpoint_type = "target"
  endpoint_id = "target-mongodb-digital-security-services-otp"
  database_name = "otp"
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
    Name = "target-mongodb-digital-security-services-otp"
  }
}