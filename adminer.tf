resource "aws_iam_user" "adminer" {
  name = "adminer-${local.resource_name}"
  tags = local.tags
}

resource "aws_iam_access_key" "adminer" {
  user = aws_iam_user.adminer.name
}

resource "aws_iam_user_policy" "adminer" {
  user   = aws_iam_user.adminer.name
  policy = data.aws_iam_policy_document.adminer.json
}

data "aws_iam_policy_document" "adminer" {
  statement {
    sid       = "ReadEnvironment"
    effect    = "Allow"
    actions   = ["elasticbeanstalk:DescribeEnvironmentResources"]
    resources = [local.env_arn]
  }
  statement {
    sid       = "ReadAutoScaling"
    effect    = "Allow"
    actions   = ["autoscaling:DescribeAutoScalingGroups"]
    resources = ["arn:aws:autoscaling:${local.region}:${local.account_id}:autoScalingGroup:*:autoScalingGroupName/*"]
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Block"
      values   = [local.block_name]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/elasticbeanstalk:environment-name"
      values   = [local.beanstalk_name]
    }
  }

  statement {
    sid       = "EnableSSMSession"
    effect    = "Allow"
    actions   = ["ssm:StartSession"]
    resources = ["arn:aws:ssm:us-east-1::document/AWS-StartSSHSession"]
  }

  statement {
    sid       = "AllowSSMSession"
    effect    = "Allow"
    actions   = ["ssm:StartSession"]
    resources = ["arn:aws:ec2:*:*:instance/*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Block"
      values   = [local.block_name]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/elasticbeanstalk:environment-name"
      values   = [local.beanstalk_name]
    }
  }
}