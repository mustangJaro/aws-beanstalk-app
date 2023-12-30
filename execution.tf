resource "aws_iam_role" "execution" {
  name               = "execution-${local.resource_name}"
  tags               = local.tags
  assume_role_policy = data.aws_iam_policy_document.execution-assume.json
}

data "aws_iam_policy_document" "execution-assume" {
  statement {
    sid     = "AllowECSAssume"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "execution-managed" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "execution" {
  role   = aws_iam_role.execution.id
  policy = data.aws_iam_policy_document.execution.json
}

locals {
  // These are used to generate an IAM policy statement to allow the app to read the secrets
  secret_arns                = [for as in aws_secretsmanager_secret.app_secret : as.arn]
  existing_arns              = values(data.ns_env_variables.this.secret_refs)
  all_arns                   = concat(local.secret_arns, local.existing_arns)
  secret_statement_resources = length(local.all_arns) > 0 ? [local.all_arns] : []
}

data "aws_iam_policy_document" "execution" {
  statement {
    sid       = "AllowPassRoleToECS"
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = [aws_iam_role.execution.arn]
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
