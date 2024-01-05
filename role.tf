resource "aws_iam_instance_profile" "this" {
  name = local.resource_name
  role = aws_iam_role.this.name
}

resource "aws_iam_role" "this" {
  name               = local.resource_name
  path               = "/"
  tags               = local.tags
  assume_role_policy = data.aws_iam_policy_document.this.json
}

data "aws_iam_policy_document" "this" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

// This policy enables SSM on the instance
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "docker" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
}

resource "aws_iam_role_policy_attachment" "web" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_role_policy_attachment" "worker" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
}
resource "aws_iam_role_policy" "execution" {
  role   = aws_iam_role.execution.id
  policy = data.aws_iam_policy_document.execution.json
}

// setup for secrets manager permissions
locals {
  // These are used to generate an IAM policy statement to allow the app to read the secrets
  secret_arns                = [for as in aws_secretsmanager_secret.app_secret : as.arn]
  existing_arns              = values(data.ns_env_variables.this.secret_refs)
  all_arns                   = concat(local.secret_arns, local.existing_arns)
  secret_statement_resources = length(local.all_arns) > 0 ? [local.all_arns] : []
}

data "aws_iam_policy_document" "this" {
  statement {
    sid       = "AllowPassRoleToBeanstalk"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [aws_iam_role.this.arn]
  }

  dynamic "statement" {
    for_each = local.secret_statement_resources

    content {
      sid       = "AllowReadSecrets"
      effect    = "Allow"
      resources = statement.value

      actions = [
        "secretsmanager:GetSecretValue",
        "kms:Decrypt"
      ]
    }
  }
}
