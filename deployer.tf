resource "aws_iam_user" "deployer" {
  name = "deployer-${local.resource_name}"
  tags = local.tags
}

resource "aws_iam_access_key" "deployer" {
  user = aws_iam_user.deployer.name
}

// The actions listed are necessary to perform 'aws s3 sync'
resource "aws_iam_user_policy" "deployer" {
  name   = "Deploy"
  user   = aws_iam_user.deployer.name
  policy = data.aws_iam_policy_document.deployer.json
}

data "aws_iam_policy_document" "deployer" {
  statement {
    sid    = "AllowFindBucket"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    resources = ["arn:aws:s3:::${local.artifacts_bucket_name}"]
  }

  statement {
    sid    = "AllowEditObjects"
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]

    resources = ["arn:aws:s3:::${local.artifacts_bucket_name}/*"]
  }
}

resource "aws_iam_user_policy_attachment" "deployer-beanstalk" {
  user       = aws_iam_user.deployer.name
  policy_arn = aws_iam_policy.deployer-beanstalk.arn
}

resource "aws_iam_policy" "deployer-beanstalk" {
  name   = "${local.resource_name}-beanstalk"
  policy = data.aws_iam_policy_document.deployer-beanstalk.json
  tags   = local.tags
}

data "aws_iam_policy_document" "deployer-beanstalk" {
  statement {
    sid       = "AllBeanstalkInApplications"
    effect    = "Allow"
    actions   = ["elasticbeanstalk:*"]
    resources = ["*"]

    condition {
      variable = "elasticbeanstalk:InApplication"
      test     = "StringEquals"
      values   = [aws_elastic_beanstalk_application.this.arn]
    }
  }

  statement {
    sid       = "AllBeanstalkOnApplications"
    effect    = "Allow"
    actions   = ["elasticbeanstalk:*"]
    resources = [aws_elastic_beanstalk_application.this.arn]
  }

  statement {
    sid       = "AllBeanstalkOnSolutionStacks"
    effect    = "Allow"
    actions   = ["elasticbeanstalk:*"]
    resources = ["arn:aws:elasticbeanstalk:${data.aws_region.this.name}::solutionstack/*"]
  }

  statement {
    sid    = "AllowS3ArtifactsAccess"
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:ListBucket",
      "s3:DeleteObject",
      "s3:GetBucketPolicy",
      "s3:CreateBucket",
      "s3:GetBucketLocation",
      "s3:GetObjectVersion"
    ]

    resources = [
      "arn:aws:s3:::elasticbeanstalk*",
      "arn:aws:s3:::elasticbeanstalk-*-${data.aws_caller_identity.this.account_id}",
      "arn:aws:s3:::elasticbeanstalk-*-${data.aws_caller_identity.this.account_id}/*"
    ]
  }

  statement {
    sid       = "AllowCloudformationForBeanstalk"
    effect    = "Allow"
    resources = ["arn:aws:cloudformation:*:${data.aws_caller_identity.this.account_id}:*"]

    actions = [
      "cloudformation:GetTemplate",
      "cloudformation:DescribeStackResources",
      "cloudformation:DescribeStackResource",
      "cloudformation:DescribeStackEvents",
      "cloudformation:DescribeStacks",
      "cloudformation:UpdateStack",
      "cloudformation:CancelUpdateStack",
      "cloudformation:ListStackResources",
    ]
  }

  statement {
    sid       = "AllowEC2ForBeanstalk"
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ec2:Describe*",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:AuthorizeSecurityGroupIngress",
      "autoscaling:SuspendProcesses",
      "autoscaling:DescribeScalingActivities",
      "autoscaling:ResumeProcesses",
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:PutNotificationConfiguration",
      "elasticloadbalancing:DescribeLoadBalancers"
    ]
  }

  statement {
    sid       = "AllowLogsForBeanstalk"
    effect    = "Allow"
    actions   = [
      "logs:CreateLogGroup",
      "logs:PutRetentionPolicy"
    ]
    resources = ["arn:aws:logs:${data.aws_region.this.name}:*:log-group:${local.log_group}"]
  }
}
