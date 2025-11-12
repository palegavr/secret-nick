variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
variable "name" {
  description = "Name for the load balancer"
  type        = string
  default     = "lb"
}

variable "vpc_id" {
  description = "ID of the VPC where the load balancer will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the load balancer"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for the load balancer"
  type        = string
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

variable "domain_name" {
  description = "The base domain name for the application"
  type        = string
}

variable "certificate_arn" {
  description = "ACM certificate arn for you domain (manual)"
  type        = string
}