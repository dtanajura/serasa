resource "aws_dms_endpoint" "source-endpoint-account" {
  engine_name = "mongodb"
  endpoint_type = "source"
  endpoint_id = "source-migracao-mongodb-account-iam-account"
  database_name = "account"
  server_name= "10.97.55.59"
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
    Name = "source-migracao-mongodb-account-iam-account"
  }
}

resource "aws_dms_endpoint" "target-endpoint-account" {
  engine_name = "docdb"
  endpoint_type = "target"
  endpoint_id = "target-mongodb-account-iam-account"
  database_name = "account"
  server_name= "10.99.133.35"
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
    Name = "target-mongodb-account-iam-account"
  }
}