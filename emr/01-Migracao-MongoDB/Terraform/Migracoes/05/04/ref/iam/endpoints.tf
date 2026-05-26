resource "aws_dms_endpoint" "source-endpoint-iam" {
  engine_name = "mongodb"
  endpoint_type = "source"
  endpoint_id = "source-migracao-mongodb-account-iam-iam"
  database_name = "iam"
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
    Name = "source-migracao-mongodb-account-iam-iam"
  }
}

resource "aws_dms_endpoint" "target-endpoint-iam" {
  engine_name = "docdb"
  endpoint_type = "target"
  endpoint_id = "target-mongodb-account-iam-iam"
  database_name = "iam"
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
    Name = "target-mongodb-account-iam-iam"
  }
}