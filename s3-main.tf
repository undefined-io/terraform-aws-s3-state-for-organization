/*
 * NOTES:
 * - You'll notice a lot of depends_on in this file. This is to prevent TF from aborting due
 *   to "A conflicting conditional operation is currently in progress against this resource."
 *   messages.
 */
resource "aws_s3_bucket" "main" {
  provider = aws.primary
  bucket   = local.main_name

  tags = var.tags

  lifecycle {
    # TODO: set to true in final version
    prevent_destroy = false
  }
}

# NOTE: No aws_s3_bucket_acl resource, since this bucket is set to BucketOwnerEnforced

resource "aws_s3_bucket_versioning" "main" {
  provider = aws.primary
  bucket   = aws_s3_bucket.main.id

  expected_bucket_owner = local.aws_primary.account_id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  provider = aws.primary
  bucket   = aws_s3_bucket.main.id

  depends_on = [
    aws_s3_bucket_versioning.main,
  ]

  expected_bucket_owner = local.aws_primary.account_id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "main" {
  provider = aws.primary
  bucket   = aws_s3_bucket.main.id

  depends_on = [
    aws_s3_bucket_server_side_encryption_configuration.main,
  ]

  expected_bucket_owner = local.aws_primary.account_id

  rule {
    id     = "multipart"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  provider = aws.primary
  bucket   = aws_s3_bucket.main.id

  depends_on = [
    aws_s3_bucket_lifecycle_configuration.main,
  ]

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "main" {
  provider = aws.primary
  bucket   = aws_s3_bucket.main.id

  depends_on = [
    aws_s3_bucket_public_access_block.main,
  ]

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_policy" "main" {
  provider = aws.primary
  bucket   = aws_s3_bucket.main.bucket
  policy = jsonencode({
    "Version" = "2012-10-17"
    "Statement" = [
      {
        "Sid"       = "DenyInsecureRequestsOnly"
        "Effect"    = "Deny"
        "Principal" = "*"
        "Action"    = "s3:*"
        "Resource"  = "${aws_s3_bucket.main.arn}/*"
        "Condition" = {
          "Bool" = {
            "aws:SecureTransport" = "false"
          }
        }
      },
      {
        "Sid"       = "DenyIncorrectEncryptionHeader"
        "Effect"    = "Deny"
        "Principal" = "*"
        "Action"    = "s3:PutObject"
        "Resource"  = "${aws_s3_bucket.main.arn}/*"
        "Condition" = {
          "StringNotEquals" = {
            "s3:x-amz-server-side-encryption" = "AES256"
          }
        }
      },
      {
        "Sid"       = "DenyUnencryptedObjectUploads"
        "Effect"    = "Deny"
        "Principal" = "*"
        "Action"    = "s3:PutObject",
        "Resource"  = "${aws_s3_bucket.main.arn}/*"
        "Condition" = {
          "Null" = {
            "s3:x-amz-server-side-encryption" = "true"
          }
        }
      },
    ]
  })

  depends_on = [
    aws_s3_bucket_ownership_controls.main,
  ]

}

# https://docs.aws.amazon.com/AmazonS3/latest/userguide/replication-time-control.html
resource "aws_s3_bucket_replication_configuration" "main" {
  provider = aws.primary
  # Must have bucket versioning enabled first
  depends_on = [
    aws_s3_bucket_versioning.main,
    aws_s3_bucket_versioning.backup,
    aws_s3_bucket_policy.main,
  ]

  role   = aws_iam_role.replication.arn
  bucket = aws_s3_bucket.main.id

  rule {
    id     = "Backup"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.backup.arn
      storage_class = "STANDARD"
    }
  }
}
