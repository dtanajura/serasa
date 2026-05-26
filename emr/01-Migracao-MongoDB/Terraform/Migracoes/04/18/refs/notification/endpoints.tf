resource "aws_dms_endpoint" "source-endpoint" {
  engine_name = "docdb"
  endpoint_type = "source"
  endpoint_id = "source-migracao-docdb-digital-services-notification"
  database_name = "notification"
  server_name= "docdb-digital-services.cluster-cxuqnyyb34lr.sa-east-1.docdb.amazonaws.com"
  username = "usr_migration"
  password = "9tw2N2wEdU7wvgTH"
  port = 27017
  ssl_mode = "verify-full"
  certificate_arn = "arn:aws:dms:sa-east-1:328257591560:cert:XDO2QOMK6JQTGQXVJPTXKWUPXYE2GBJ5J6V5M7I"
  tags = {
    Name = "source-migracao-docdb-digital-services-notification"
  }
}

resource "aws_dms_endpoint" "target-endpoint" {
  engine_name = "docdb"
  endpoint_type = "target"
  endpoint_id = "destination-migracao-mongodb-digital-services-notification"
  database_name = "notification"
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
    Name = "destination-migracao-mongodb-digital-services-notification"
  }
}

output "source_endpoint_arn" {
  value = aws_dms_endpoint.source-endpoint.endpoint_arn
}

output "target_endpoint_arn" {
  value = aws_dms_endpoint.target-endpoint.endpoint_arn
}