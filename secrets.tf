locals {
  // Since Beanstalk does not have secret injection, we are going to add a list of env vars mapping the secret ids
  // e.g. POSTGRES_URL => POSTGRES_URL_SECRET_ID = <secret-id>
  app_secret_ids  = { for key in local.secret_keys : "${key}_SECRET_ID" => aws_secretsmanager_secret.app_secret[key].id }
  app_secret_arns = [for key in local.secret_keys : aws_secretsmanager_secret.app_secret[key].arn]
}

resource "aws_secretsmanager_secret" "app_secret" {
  for_each = local.secret_keys

  name_prefix = "${local.block_name}/${each.value}/"
  tags        = local.tags
  kms_key_id  = aws_kms_alias.this.arn

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_secretsmanager_secret_version" "app_secret" {
  for_each = local.secret_keys

  secret_id     = aws_secretsmanager_secret.app_secret[each.value].id
  secret_string = local.all_secrets[each.value]

  lifecycle {
    create_before_destroy = true
  }
}

// setup for secrets manager permissions
locals {
  // These are used to generate an IAM policy statement to allow the app to read the secrets
  secret_arns                = [for as in aws_secretsmanager_secret.app_secret : as.arn]
  all_arns                   = concat(local.secret_arns, local.app_secret_arns)
  secret_statement_resources = length(local.all_arns) > 0 ? [local.all_arns] : []
}

data "aws_iam_policy_document" "secrets" {
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
