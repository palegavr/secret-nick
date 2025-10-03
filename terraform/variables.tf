################################
# Global Variables
################################

variable "aws_region" {
  description = "AWS region on where to deploy"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

################################
# VPC Variables
################################

variable "vpc_name" {
  description = "VPC name"
  type        = string
}
variable "vpc_cidr" {
  description = "Your VPC adress block"
  type        = string
}

variable "subnets" {
  description = "List of subnets"
  type = map(object({
    cidr_block = string
    public     = bool
    az_index   = optional(number)
  }))
}

################################################################################
# Security Groups
################################################################################

variable "name_prefix" {
  description = "Prefix for naming security groups"
  type        = string
}

variable "rds_port" {
  description = "Port for RDS database"
  type        = number
}

variable "project_name" {
  description = "Name of the project, used as prefix for resources"
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

variable "node_exporter_port" {
  description = "Port for Node Exporter service"
  type        = number
}

variable "alb_ingress_ports" {
  description = "Ports to allow on ALB"
  type        = list(number)
}

variable "alb_ingress_cidr" {
  description = "CIDR blocks for ALB ingress"
  type        = list(string)
}

variable "az_letter" {
  description = "Availability zone letter suffix (a, b, c, etc.)"
  type        = string
}

################################################################################
# Instance
################################################################################

variable "subnet" {
  description = "Subnet id"
  type        = string
}

variable "sgs" {
  description = "Security Groups ids"
  type        = list(string)
  default     = [""]
}

variable "ami" {
  description = "ID of AMI to use for the instance"
  type        = string
  default     = null
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address with an instance in a VPC"
  type        = bool
  default     = null
}

variable "availability_zone" {
  description = "AZ to start the instance in"
  type        = string
  default     = null
}

variable "iam_instance_profile" {
  description = "IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile"
  type        = string
  default     = null
}

variable "instance_type" {
  description = "The type of instance to start"
  type        = string
  default     = "t3.micro"
}

variable "ec2_name_set" {
  description = "Set of names for EC2 VMs"
  type        = set(string)
  default     = []
}

################################################################################
# IAM Role / Instance Profile
################################################################################

variable "create_iam_instance_profile" {
  description = "Determines whether an IAM instance profile is created or to use an existing IAM instance profile"
  type        = bool
  default     = false
}

variable "iam_role_name" {
  description = "Name to use on IAM role created"
  type        = string
  default     = null
}

variable "iam_role_use_name_prefix" {
  description = "Determines whether the IAM role name (`iam_role_name` or `name`) is used as a prefix"
  type        = bool
  default     = true
}

variable "iam_role_path" {
  description = "IAM role path"
  type        = string
  default     = null
}

variable "iam_role_policies" {
  description = "Policies attached to the IAM role"
  type        = map(string)
  default     = {}
}

################################
# RDS
################################

variable "db_id" {
  description = "The RDS instance identifier, also used as a 'Name' tag for the DB"
  type        = string
}

variable "db_username" {
  description = "Master username for the database"
  type        = string
  sensitive   = true
}

variable "db_engine" {
  description = "The database engine to use for the RDS instance"
  type        = string
}

variable "db_engine_version" {
  description = "The version of the database engine"
  type        = string
}

variable "db_instance_class" {
  description = "The instance type for the RDS instance"
  type        = string
  default     = "db.t3.micro"
}

variable "db_storage_size" {
  description = "Size of the RDS instance storage in GB."
  type        = number
  default     = 20
}

variable "db_subnet_group_name" {
  description = "The name of the subnet group where RDS instance is placed"
  type        = string
}

################################
# SSL
################################

variable "domain_name" {
  description = "The base domain name for the application"
  type        = string
}

variable "certificate_arn" {
  description = "ACM certificate arn for you domain (manual)"
  type        = string
}