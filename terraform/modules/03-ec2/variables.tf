variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

################################################################################
# Instance
################################################################################

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
  default     = "t2.micro"
}

variable "ec2_name" {
  description = "Name to be used on EC2 instance created"
  type        = string
  default     = ""
}

variable "ec2_name_set" {
  description = "Set of names for EC2 VMs"
  type        = set(string)
  default     = []
}

variable "sgs" {
  description = "Security Groups ids"
  type        = list(string)
  default     = [""]
}

variable "subnet" {
  description = "Subnet id"
  type        = string
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

variable "iam_role_description" {
  description = "Description of the role"
  type        = string
  default     = null
}

variable "iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "iam_role_tags" {
  description = "A map of additional tags to add to the IAM role/profile created"
  type        = map(string)
  default     = {}
}

variable "iam_role_policies" {
  description = "Policies attached to the IAM role"
  type        = map(string)
  default     = {}
}
variable "web_ui_port" {
  description = "Port for Web UI service"
  type        = number
}

variable "target_group_arn" {
  description = "ARN of the target group to attach the instance to"
  type        = string
  default     = null
}

variable "web_backend_port" {
  description = "Port for the web backend service"
  type        = number
  default     = 8080
}

variable "prometheus_port" {
  description = "Port for Prometheus service"
  type        = number
  default     = 9090
}

variable "grafana_port" {
  description = "Port for Grafana service"
  type        = number
  default     = 3001
}

variable "node_exporter_port" {
  description = "Port for Node Exporter service"
  type        = number
  default     = 9100
}

variable "ports" {
  description = "List of ports that should be allowed on this EC2"
  type        = list(number)
  default     = []
}

variable "port" {
  description = "Port for the service"
  type        = number
  default     = 3000
}