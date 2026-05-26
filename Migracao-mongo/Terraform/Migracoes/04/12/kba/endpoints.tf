resource "aws_dms_endpoint" "source-migracao-docdb-digital-kyc-services-kba" {
  engine_name = "docdb"
  endpoint_type = "source"
  endpoint_id = "source-migracao-docdb-digital-kyc-services-kba"
  database_name = "kba"
  server_name= "docdb-digital-kyc-services.cluster-cxuqnyyb34lr.sa-east-1.docdb.amazonaws.com"
  username = "usr_migration"
  password = "9tw2N2wEdU7wvgTH"
  port = 27017
  ssl_mode = "verify-full"
  certificate_arn = "arn:aws:dms:sa-east-1:328257591560:cert:XDO2QOMK6JQTGQXVJPTXKWUPXYE2GBJ5J6V5M7I"
  tags = {
    Name = "source-migracao-docdb-digital-kyc-services-kba"
  }
}

resource "aws_dms_endpoint" "destination-migracao-mongodb-digital-kyc-services-kba" {
  engine_name = "docdb"
  endpoint_type = "target"
  endpoint_id = "destination-migracao-mongodb-digital-kyc-services-kba"
  database_name = "kba"
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
    Name = "destination-migracao-mongodb-digital-kyc-services-kba"
  }
}