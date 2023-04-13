/*
 * NOTES:
 * - You'll notice a lot of depends_on in this file. This is to prevent TF from aborting due
 *   to "A conflicting conditional operation is currently in progress against this resource."
 *   messages.
 */
resource "aws_s3_bucket" "backup" {
  provider = aws.secondary
  bucket   = local.backup_name

  tags = var.tags

  lifecycle {
    # TODO: set to true in final version
    prevent_destroy = false
  }
}

# NOTE: No aws_s3_bucket_acl resource, since this bucket is set to BucketOwnerEnforced

resource "aws_s3_bucket_versioning" "backup" {
  provider = aws.secondary
  bucket   = aws_s3_bucket.backup.id

  expected_bucket_owner = local.aws_secondary.account_id

  versioning_configuration {
    status     = "Enabled"
    mfa_delete = "Disabled"
    # TODO: It's tricky turning on MFA Delete via Terraform, will revisit this
    # https://docs.aws.amazon.com/AmazonS3/latest/userguide/MultiFactorAuthenticationDelete.html
    # https://github.com/hashicorp/terraform-provider-aws/issues/8560
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "backup" {
  provider = aws.secondary
  bucket   = aws_s3_bucket.backup.id

  depends_on = [
    aws_s3_bucket_versioning.backup,
  ]

  expected_bucket_owner = local.aws_secondary.account_id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "backup" {
  provider = aws.secondary
  bucket   = aws_s3_bucket.backup.id

  depends_on = [
    aws_s3_bucket_server_side_encryption_configuration.backup,
  ]

  expected_bucket_owner = local.aws_secondary.account_id

  rule {
    id     = "multipart"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }
}

resource "aws_s3_bucket_public_access_block" "backup" {
  provider = aws.secondary
  bucket   = aws_s3_bucket.backup.id

  depends_on = [
    aws_s3_bucket_lifecycle_configuration.backup,
  ]

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "backup" {
  provider = aws.secondary
  bucket   = aws_s3_bucket.backup.id

  depends_on = [
    aws_s3_bucket_public_access_block.backup,
  ]

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# TODO: temporarily removed bucket policy
resource "aws_s3_bucket_policy" "backup" {
  provider   = aws.secondary
  depends_on = [aws_s3_bucket_ownership_controls.backup]
  bucket     = aws_s3_bucket.backup.bucket
  policy = jsonencode({
    "Version" = "2012-10-17"
    "Statement" = [
      # These IaC ones will likely morph into deny for anyone buta the
      #   iac_principal_arn, using the "Condition.ArnNotEquals.aws:PrincipalArn"
      {
        "Sid"       = "AllowIaCAccessBucket"
        "Effect"    = "Allow"
        "Principal" = { "AWS" = var.iac_principal_arn }
        "Action" = [
          "s3:*AccelerateConfiguration",
          "s3:*Bucket",
          "s3:*BucketAcl",
          "s3:*BucketCORS",
          "s3:*BucketLogging",
          "s3:*BucketObjectLockConfiguration",
          "s3:*BucketOwnershipControls",
          "s3:*BucketPolicy",
          "s3:*BucketPublicAccessBlock",
          "s3:*BucketRequestPayment",
          "s3:*BucketTagging",
          "s3:*BucketVersioning",
          "s3:*BucketWebsite",
          "s3:*EncryptionConfiguration",
          "s3:*LifecycleConfiguration",
          "s3:*ReplicationConfiguration",
        ],
        "Resource" = aws_s3_bucket.backup.arn
      },
      {
        "Sid"       = "AllowIaCAccessService"
        "Effect"    = "Allow"
        "Principal" = { "AWS" = var.iac_principal_arn }
        "Action"    = "s3:*BucketOwnershipControls"
        "Resource"  = aws_s3_bucket.backup.arn
      },
    ]
  })
}
