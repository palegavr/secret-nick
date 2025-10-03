output "lb_id" {
  description = "The ID of the load balancer"
  value       = aws_lb.this.id
}

output "lb_arn" {
  description = "The ARN of the load balancer"
  value       = aws_lb.this.arn
}

output "lb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.this.dns_name
}

output "lb_zone_id" {
  description = "The canonical hosted zone ID of the load balancer"
  value       = aws_lb.this.zone_id
}

output "web_ui_angular_target_group_arn" {
  description = "ARN of the Angular web UI target group"
  value       = aws_lb_target_group.web_ui_angular.arn
}

output "web_ui_react_target_group_arn" {
  description = "ARN of the Web UI target group"
  value       = aws_lb_target_group.web_ui_react.arn
}

output "grafana_target_group_arn" {
  description = "ARN of the Grafana target group"
  value       = aws_lb_target_group.grafana.arn
}

output "prometheus_target_group_arn" {
  description = "ARN of the Prometheus target group"
  value       = aws_lb_target_group.prometheus.arn
}

output "alb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.this.dns_name
}

output "backend_target_group_arn" {
  description = "The ARN of the backend target group"
  value       = aws_lb_target_group.backend.arn
}