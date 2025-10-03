data "aws_partition" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  instance_id = try(
    aws_instance.this.id,
    null,
  )

  user_data = <<-EOT
    #!/bin/bash
    yum update -y
    yum install -y docker
    service docker enable
    service docker start
    usermod -a -G docker ec2-user
  EOT
}

################################################################################
# IAM Role / Instance Profile
################################################################################

data "aws_iam_policy_document" "assume_role_policy" {
  count = var.create_iam_instance_profile ? 1 : 0

  statement {
    sid     = "EC2AssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.${data.aws_partition.current.dns_suffix}"]
    }
  }
}

locals {
  iam_role_name = try(coalesce(var.iam_role_name, var.ec2_name), "")
}

resource "aws_iam_role" "this" {
  count = var.create_iam_instance_profile ? 1 : 0

  name        = var.iam_role_use_name_prefix ? null : local.iam_role_name
  name_prefix = var.iam_role_use_name_prefix ? "${local.iam_role_name}-" : null
  path        = var.iam_role_path
  description = var.iam_role_description

  assume_role_policy    = data.aws_iam_policy_document.assume_role_policy[0].json
  force_detach_policies = true

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "prometheus_ec2_discovery" {
  count      = var.ec2_name == "prometheus" ? 1 : 0
  role       = aws_iam_role.this[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}


resource "aws_iam_role_policy_attachment" "this" {
  for_each = { for k, v in var.iam_role_policies : k => v if var.create_iam_instance_profile }

  policy_arn = each.value
  role       = aws_iam_role.this[0].name
}

resource "aws_iam_instance_profile" "this" {
  count = var.create_iam_instance_profile ? 1 : 0

  role = aws_iam_role.this[0].name

  name        = var.iam_role_use_name_prefix ? null : local.iam_role_name
  name_prefix = var.iam_role_use_name_prefix ? "${local.iam_role_name}-" : null
  path        = var.iam_role_path

  tags = merge(var.tags, var.iam_role_tags)

  lifecycle {
    create_before_destroy = true
  }
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

################################################################################
# Instance
################################################################################

resource "aws_instance" "this" {
  ami                         = var.ami
  associate_public_ip_address = var.associate_public_ip_address
  availability_zone           = data.aws_availability_zones.available.names[0]
  iam_instance_profile        = var.create_iam_instance_profile ? aws_iam_instance_profile.this[0].name : var.iam_instance_profile
  instance_type               = var.instance_type
  subnet_id                   = var.subnet
  vpc_security_group_ids      = var.sgs
  user_data_base64            = base64encode(local.user_data)
  user_data_replace_on_change = false

  tags = merge(
    { "Name" = var.ec2_name },
    var.tags
  )
}

resource "aws_lb_target_group_attachment" "this" {

  count = contains(["angular", "react", "dotnet", "grafana", "prometheus"], var.ec2_name) ? 1 : 0


  target_group_arn = var.target_group_arn
  target_id        = aws_instance.this.id
  port             = local.ec2_ports_map[var.ec2_name][0]

  depends_on = [aws_instance.this]
}