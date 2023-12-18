resource "aws_elastic_beanstalk_application" "this" {
  name = local.resource_name
  tags = local.tags
}

locals {
  // Beanstalk requires an environment name to be at least 4 characters
  // Since some may name their nullstone env "dev", AWS errors when trying to create the beanstalk environment
  // beanstalk_env adds a suffix to ensure the environment name is long enough
  beanstalk_env = "${local.env_name}-${random_string.resource_suffix.result}"

  // Settings Reference: https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/command-options-general.html
  basic_settings = [    
    {
      namespace = "aws:ec2:instances"
      name      = "InstanceTypes"
      value     = join(",", [var.instance_type])
    },
    {
      namespace = "aws:ec2:vpc"
      name      = "ELBScheme"
      value     = "public"
    },
    {
      namespace = "aws:ec2:vpc"
      name      = "ELBSubnets"
      value     = join(",", sort(local.public_subnet_ids))
    },
    {
      namespace = "aws:ec2:vpc"
      name      = "Subnets"
      value     = join(",", sort(local.private_subnet_ids))
    },
    {
      namespace = "aws:ec2:vpc"
      name      = "VPCId"
      value     = local.vpc_id
    },
    {
      namespace = "aws:autoscaling:launchconfiguration"
      name      = "IamInstanceProfile"
      value     = aws_iam_instance_profile.this.name
    },
    {
      namespace = "aws:autoscaling:launchconfiguration"
      name      = "SecurityGroups"
      value     = join(",", [aws_security_group.this.id])
    },
    {
      namespace = "aws:elasticbeanstalk:cloudwatch:logs"
      name      = "StreamLogs"
      value     = true
    }
  ]
  cap_settings = lookup(local.capabilities, "settings", [])
  all_settings = { for setting in concat(local.basic_settings, local.cap_settings) : "${setting.namespace}/${setting.name}" => setting }
}

resource "aws_elastic_beanstalk_environment" "this" {
  application         = aws_elastic_beanstalk_application.this.name
  name                = local.beanstalk_env
  tags                = local.tags
  solution_stack_name = var.stack
  tier                = "WebServer"

  dynamic "setting" {
    for_each = local.all_settings

    content {
      namespace = setting.value.namespace
      name      = setting.value.name
      value     = setting.value.value
    }
  }
}
