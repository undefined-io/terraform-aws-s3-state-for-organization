resource "aws_iam_role" "replication" {
  provider = aws.primary
  name     = "${local.name}-replication"
  tags     = var.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid"    = "AllowPrimaryToAssumeServiceRole"
        "Effect" = "Allow"
        "Action" = "sts:AssumeRole"
        "Principal" = {
          "Service" = "s3.amazonaws.com"
        }
      }
    ]
  })

  inline_policy {
    name = "StateFileReplication"
    policy = jsonencode({
      "Version" = "2012-10-17"
      "Statement" = [
        {
          "Sid"    = "AllowPrimaryToGetReplicationConfiguration",
          "Effect" = "Allow"
          "Action" = [
            "s3:ListBucket",
            "s3:Get*"
          ],
          "Resource" = [
            aws_s3_bucket.main.arn,
            "${aws_s3_bucket.main.arn}/*"
          ],
        },
        {
          "Sid"    = "AllowPrimaryToReplicate",
          "Effect" = "Allow"
          "Action" = [
            "s3:ReplicateTags",
            "s3:ReplicateObject",
            "s3:ReplicateDelete",
            "s3:GetObjectVersionTagging"
          ],
          "Resource" = [
            "${aws_s3_bucket.backup.arn}/*"
          ],
        }
      ]
    })
  }
}
