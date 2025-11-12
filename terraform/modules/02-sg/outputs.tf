################################################################################
# SG
################################################################################

output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = try(aws_security_group.alb.id, null)
}

output "web_backend_security_group_id" {
  description = "ID of the Web Backend security group"
  value       = try(aws_security_group.web_backend.id, null)
}

output "web_ui_security_group_id" {
  description = "ID of the Web UI security group"
  value       = try(aws_security_group.web_ui.id, null)
}

output "prometheus_security_group_id" {
  description = "ID of the Prometheus security group"
  value       = try(aws_security_group.prometheus.id, null)
}

output "grafana_security_group_id" {
  description = "ID of the Grafana security group"
  value       = try(aws_security_group.grafana.id, null)
}

output "node_exporter_security_group_id" {
  description = "ID of the Node Exporter security group"
  value       = try(aws_security_group.node_exporter.id, null)
}

output "rds_instance_security_group_id" {
  description = "ID of the RDS instance security group"
  value       = try(aws_security_group.rds.id, null)
}

output "security_groups" {
  description = "Map of all security groups"
  value = {
    alb          = aws_security_group.alb.id
    web_backend  = aws_security_group.web_backend.id
    web_ui       = aws_security_group.web_ui.id
    rds_instance = aws_security_group.rds.id
    prometheus   = aws_security_group.prometheus.id
    grafana      = aws_security_group.grafana.id
    node_exporter = aws_security_group.node_exporter.id
  }
}
output "rds_security_group_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.rds.id
}