resource "aws_dms_endpoint" "source-migracao-docdb-digital-account-services-mkt-automation" {
  engine_name = "docdb"
  endpoint_type = "source"
  endpoint_id = "source-migracao-docdb-digital-account-services-mkt-automation"
  database_name = "marketingAutomation"
  server_name= "docdb-digital-account-services.cluster-cxuqnyyb34lr.sa-east-1.docdb.amazonaws.com"
  username = "usr_migration"
  password = "9tw2N2wEdU7wvgTH"
  port = 27017
  ssl_mode = "verify-full"
  certificate_arn = "arn:aws:dms:sa-east-1:328257591560:cert:XDO2QOMK6JQTGQXVJPTXKWUPXYE2GBJ5J6V5M7I"
  tags = {
    Name = "source-migracao-docdb-digital-account-services-mkt-automation"
  }
}

resource "aws_dms_endpoint" "destination-migracao-mongodb-account-iam-mkt-automation" {
  engine_name = "docdb"
  endpoint_type = "target"
  endpoint_id = "destination-migracao-mongodb-account-iam-mkt-automation"
  database_name = "marketingAutomation"
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
    Name = "destination-migracao-mongodb-account-iam-mkt-automation"
  }
}