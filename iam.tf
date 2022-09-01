resource "aws_iam_role" "state" {
  provider = aws.primary
  name     = "${var.name}-state"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
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
            "aws:PrincipalArn" = local.role_access_arn_list
          }
        }
      }
    ]
  })

  # Policy to allow a user to start a GDS Job on-demand
  # This is restricted only to job cluster (eg. j01, j02, etc.)
  inline_policy {
    name = "StateFileAccess"
    policy = jsonencode({
      "Version" = "2012-10-17"
      "Statement" = [
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

