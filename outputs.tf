output "region" {
  value       = data.aws_region.this.name
  description = "string ||| The region the lambda was created."
}

output "artifacts_bucket_arn" {
  value       = aws_s3_bucket.artifacts.arn
  description = "string ||| The ARN of the created S3 bucket used for deployment artifacts."
}

output "artifacts_bucket_name" {
  value       = aws_s3_bucket.artifacts.bucket
  description = "string ||| The name of the created S3 bucket used for deployment artifacts."
}

output "artifacts_key_template" {
  value       = "{{app-version}}/app.zip"
  description = "string ||| Template for s3 object key that is used for Beanstalk App Version ({{app-version}} is replaced with the app-version)"
}

output "deployer" {
  value = {
    name       = aws_iam_user.deployer.name
    access_key = aws_iam_access_key.deployer.id
    secret_key = aws_iam_access_key.deployer.secret
  }

  description = "object({ name: string, access_key: string, secret_key: string }) ||| An AWS User with explicit privilege to deploy to the S3 bucket."

  sensitive = true
}

output "beanstalk_name" {
  value       = aws_elastic_beanstalk_application.this.name
  description = "string ||| Elastic Beanstalk App Name"
}

output "beanstalk_arn" {
  value       = aws_elastic_beanstalk_application.this.arn
  description = "string ||| Elastic Beanstalk App ARN"
}

output "environment_id" {
  value       = aws_elastic_beanstalk_environment.this.id
  description = "string ||| The ID of the this Elastic Beanstalk Environment"
}

locals {
  // Private and public URLs are shown in the Nullstone UI
  // Typically, they are created through capabilities attached to the application
  // If this module has URLs, add them here as list(string) 
  additional_private_urls = []
  additional_public_urls  = [aws_elastic_beanstalk_environment.this.endpoint_url]
}

output "private_urls" {
  value       = concat([for url in try(local.capabilities.private_urls, []) : url["url"]], local.additional_private_urls)
  description = "list(string) ||| A list of URLs only accessible inside the network"
}

output "public_urls" {
  value       = concat([for url in try(local.capabilities.public_urls, []) : url["url"]], local.additional_public_urls)
  description = "list(string) ||| A list of URLs accessible to the public"
}
