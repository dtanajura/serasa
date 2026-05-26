# Create a new replication instance
resource "aws_dms_replication_instance" "migracao-bancos-mongo" {
  allocated_storage            = var.tamanhoDisco
  apply_immediately            = true
  auto_minor_version_upgrade   = true
  engine_version               = "3.4.7"
  multi_az                     = true
  preferred_maintenance_window = "sun:10:30-sun:14:30"
  publicly_accessible          = false
  replication_instance_class   = var.instanceSize
  replication_instance_id      = "migracao-bancos-mongo"
  replication_subnet_group_id  = var.subnetGroupId
  vpc_security_group_ids = var.securityGroupsIds
}
