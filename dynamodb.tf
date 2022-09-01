resource "aws_dynamodb_table" "locks" {
  name         = "${var.name}-locks"
  billing_mode = "PAY_PER_REQUEST"

  # https://www.terraform.io/docs/backends/types/s3.html#dynamodb_table
  hash_key = "LockID"

  # While no sensitive, it also makes no sense not to encrypt these.
  server_side_encryption {
    enabled = true
  }

  # For these lock tables, we really are not focused on backups.
  point_in_time_recovery {
    enabled = false
  }

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = var.tags
}

