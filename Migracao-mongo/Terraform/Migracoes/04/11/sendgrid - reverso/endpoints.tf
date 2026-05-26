resource "aws_dms_endpoint" "destination-reverso-mongodb-digital-persona-video-loan-sendgrid" {
  engine_name = "docdb"
  endpoint_type = "target"
  endpoint_id = "destination-reverso-mongodb-digital-persona-video-loan-sendgrid"
  database_name = "sendgrid"
  server_name= "10.97.55.81"
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
    Name = "destination-reverso-mongodb-digital-persona-video-loan-sendgrid"
  }
}

resource "aws_dms_endpoint" "source-reverso-mongodb-digital-services-sendgrid" {
  engine_name = "mongodb"
  endpoint_type = "source"
  endpoint_id = "source-reverso-mongodb-digital-services-sendgrid"
  database_name = "sendgrid"
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
    Name = "source-reverso-mongodb-digital-services-sendgrid"
  }

}