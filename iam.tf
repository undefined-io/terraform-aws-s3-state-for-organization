resource "aws_iam_role" "state" {
  provider = aws.primary
  name     = "${local.name}-state"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    # keep only statements that are not null
    Statement = [for v in [
      # if no permission-sets were passed in, skip this block
      (length(local.permission_set_arn_list) > 0 ? {
        "Sid"    = "PermissionSets"
        "Effect" = "Allow"
        "Action" = "sts:AssumeRole"
        # NOTE: AWS will show the following in the IAM console
        # "Broad access: Principals that include a wildcard (*, ?) can be overly permissive."
        # This is misleading, because the "Condition" in this actually is very limited.
        "Principal" = {
          "AWS" = "*"
        },
        "Condition" = {
          "ArnEquals" = {
            "aws:PrincipalArn" = local.permission_set_arn_list
          },
          "StringEquals" : {
            "aws:PrincipalOrgID" : local.organization_id
          }
        }
      } : null),
      # if no roles were passed in, skip this block
      (length(var.aws_principal_arn) > 0 ? {
        "Sid"    = "SpecifcRoles"
        "Effect" = "Allow"
        "Action" = "sts:AssumeRole"
        "Principal" = {
          "AWS" = var.aws_principal_arn
        }
      } : null)
    ] : v if v != null]
  })

  inline_policy {
    name = "StateFileAccess"
    policy = jsonencode({
      "Version" = "2012-10-17"
      "Statement" = [
        # S3 Bucket
        {
          "Effect"   = "Allow"
          "Action"   = "s3:ListBucket"
          "Resource" = aws_s3_bucket.main.arn
        },
        {
          "Effect" = "Allow",
          "Action" = [
            "s3:GetObject",
            "s3:PutObject",
            "s3:DeleteObject"
          ]
          "Resource" = "${aws_s3_bucket.main.arn}/*"
        },
        # Locking Table
        {
          "Effect" = "Allow"
          "Action" = [
            "dynamodb:GetItem",
            "dynamodb:PutItem",
            "dynamodb:DeleteItem"
          ]
          "Resource" = aws_dynamodb_table.locks.arn
        }
      ]
    })
  }

  tags = var.tags
}

