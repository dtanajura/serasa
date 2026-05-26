resource "aws_dms_endpoint" "source-endpoint" {
  engine_name = "mongodb"
  endpoint_type = "source"
  endpoint_id = "source-migracao-mongodb-customer-relationship-leadinfo"
  database_name = "leadinfo"
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
    Name = "source-migracao-mongodb-customer-relationship-leadinfo"
  }
 }

 resource "aws_dms_endpoint" "target-endpoint" {
  engine_name = "docdb"
  endpoint_type = "target"
  endpoint_id = "destination-migracao-mongodb-account-iam-leadinfo"
  database_name = "leadinfo"
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
    Name = "destination-migracao-mongodb-account-iam-leadinfo"
  }
}

 
output "source_endpoint_arn" {
  value = aws_dms_endpoint.source-endpoint.endpoint_arn
}

output "target_endpoint_arn" {
  value = aws_dms_endpoint.target-endpoint.endpoint_arn
}