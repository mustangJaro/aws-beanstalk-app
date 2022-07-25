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

  statement {
    sid       = "AllowBeanstalkAdminApp"
    effect    = "Allow"
    resources = [aws_elastic_beanstalk_application.this.arn]
    actions   = ["beanstalk:CreateApplicationVersion"]
  }

  statement {
    sid       = "AllowBeanstalkDeploy"
    effect    = "Allow"
    resources = [aws_elastic_beanstalk_environment.this.arn]

    actions = [
      "beanstalk:UpdateEnvironment",
      "beanstalk:DescribeEnvironments",
    ]

    condition {
      variable = "elasticbeanstalk:InApplication"
      test     = "ArnEquals"
      values   = [aws_elastic_beanstalk_application.this.arn]
    }
  }
}
