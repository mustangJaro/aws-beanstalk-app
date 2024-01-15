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
    sid     = "AllowSSMSession"
    effect  = "Allow"
    actions = ["elasticbeanstalk:DescribeEnvironmentResources"]
    resources = [aws_elastic_beanstalk_application.this.arn]
  }
}