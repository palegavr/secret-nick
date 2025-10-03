################################################################################
# VPC/network
################################################################################

module "vpc" {
  source   = "./modules/01-vpc"
  vpc_cidr = var.vpc_cidr
  vpc_name = var.vpc_name
  subnets  = var.subnets
}

################################################################################
# Security Groups
################################################################################

module "security_groups" {
  source = "./modules/02-sg"

  vpc_id      = module.vpc.vpc_id
  name_prefix = var.project_name

  # Port settings
  web_backend_port = var.web_backend_port
  web_ui_port      = var.web_ui_port
  rds_port         = var.rds_port
  prometheus_port  = var.prometheus_port
  grafana_port     = var.grafana_port
  node_exporter_port = var.node_exporter_port

  # Access settings
  alb_ingress_ports = var.alb_ingress_ports
  alb_ingress_cidr  = var.alb_ingress_cidr

  tags = var.tags
}

################################################################################
# EC2
################################################################################
module "ec2" {
  for_each = toset(var.ec2_name_set)

  source   = "./modules/03-ec2"
  ami      = var.ami
  sgs      = each.key == "dotnet" ? [module.security_groups.web_backend_security_group_id, module.security_groups.node_exporter_security_group_id] : (each.key == "prometheus" ? [module.security_groups.prometheus_security_group_id] : (each.key == "grafana" ? [module.security_groups.grafana_security_group_id] : [module.security_groups.web_ui_security_group_id, module.security_groups.node_exporter_security_group_id]))
  ec2_name = each.key
  #place dotnet(backend) to private subnet
  subnet                      = module.vpc.vpc_subnet_ids["subnet0"]
  instance_type               = var.instance_type
  create_iam_instance_profile = true
  iam_role_description        = "IAM role for EC2 instance"
  iam_role_policies           = var.iam_role_policies
  web_ui_port                 = var.web_ui_port
  web_backend_port            = var.web_backend_port
  prometheus_port             = var.prometheus_port
  grafana_port                = var.grafana_port
  node_exporter_port          = var.node_exporter_port
  ports                       = local.ec2_ports_map[each.key]
  target_group_arn = each.key == "angular" ? module.alb.web_ui_angular_target_group_arn : each.key == "react" ? module.alb.web_ui_react_target_group_arn : each.key == "grafana" ? module.alb.grafana_target_group_arn : each.key == "prometheus" ? module.alb.prometheus_target_group_arn : null
  associate_public_ip_address = true

}

################################################################################
# RDS
################################################################################

module "rds" {
  source               = "./modules/04-rds"
  db_id                = var.db_id
  db_username          = var.db_username
  db_subnet_group_name = var.db_subnet_group_name
  rds_port             = var.rds_port
  db_engine            = var.db_engine
  db_engine_version    = var.db_engine_version
  db_storage_size      = var.db_storage_size
  db_instance_class    = var.db_instance_class
  db_vpc_sg_ids        = [module.security_groups.rds_instance_security_group_id]
  vpc_subnet_ids       = module.vpc.private_subnet_ids
}

################################################################################
# ALB
################################################################################

module "alb" {
  source            = "./modules/05-alb"
  tags              = var.tags
  name              = "${var.project_name}-alb"
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.public_subnet_ids
  security_group_id = module.security_groups.alb_security_group_id
  web_backend_port  = var.web_backend_port
  web_ui_port       = var.web_ui_port
  prometheus_port   = var.prometheus_port
  grafana_port      = var.grafana_port
  domain_name       = var.domain_name
  certificate_arn   = var.certificate_arn
}


################################################################################
# Locals
################################################################################

locals {
  ec2_ports_map = {
    react      = [var.web_ui_port, var.node_exporter_port]
    angular    = [var.web_ui_port, var.node_exporter_port]
    dotnet     = [var.web_backend_port, var.node_exporter_port]
    prometheus = [var.prometheus_port]
    grafana    = [var.grafana_port]
  }
}