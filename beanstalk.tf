resource "aws_elastic_beanstalk_application" "this" {
  name = local.resource_name
  tags = local.tags
}

locals {
  // Beanstalk requires an environment name to be at least 4 characters
  // Since some may name their nullstone env "dev", AWS errors when trying to create the beanstalk environment
  // This local adds padding to the env name to ensure the beanstalk environment name is valid
  beanstalk_env = length(local.env_name) >= 4 ? local.env_name : "${local.env_name}${substr("____", 0, 4-length(local.env_name))}"
}

resource "aws_elastic_beanstalk_environment" "this" {
  application         = aws_elastic_beanstalk_application.this.name
  name                = local.beanstalk_env
  tags                = local.tags
  solution_stack_name = var.stack
  tier                = "WebServer"

  // Settings Reference: https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/command-options-general.html

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBScheme"
    value     = "public"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = join(",", sort(local.public_subnet_ids))
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.this.name
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = join(",", [aws_security_group.this.id])
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", sort(local.private_subnet_ids))
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = local.vpc_id
  }
}
