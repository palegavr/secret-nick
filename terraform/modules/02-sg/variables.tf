variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for naming security groups"
  type        = string
}

variable "alb_ingress_cidr" {
  description = "CIDR blocks for ALB ingress"
  type        = list(string)
}

variable "alb_ingress_ports" {
  description = "Ports to allow on ALB"
  type        = list(number)
}

variable "web_backend_port" {
  description = "Port for Web Backend service"
  type        = number
}

variable "web_ui_port" {
  description = "Port for Web UI service"
  type        = number
}

variable "prometheus_port" {
  description = "Port for Prometheus service"
  type        = number
}

variable "grafana_port" {
  description = "Port for Grafana service"
  type        = number
}

variable "node_exporter_port" {
  description = "Port for Node Exporter service"
  type        = number
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "rds_port" {
  description = "Port for RDS database"
  type        = number
}