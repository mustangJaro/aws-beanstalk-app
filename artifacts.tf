locals {
  artifacts_bucket_name = "artifacts-${local.resource_name}"
}

resource "aws_s3_bucket" "artifacts" {
  bucket              = local.artifacts_bucket_name
  tags                = local.tags
  force_destroy       = true
  object_lock_enabled = true
}

resource "aws_s3_bucket_ownership_controls" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_acl" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id
  acl    = "private"

  depends_on = [aws_s3_bucket_ownership_controls.artifacts]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}
