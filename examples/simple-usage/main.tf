resource "random_string" "sample" {
  special = false
  upper   = false
  length  = 4
}

locals {
  name = "tassfo-test"
  id   = random_string.sample.id
  tags = {
    # Use any tags that are applicable and not already covered by default_tags
    Owner          = "DevOps"
    App            = "Sample"
    GitHub         = "https://github.com/sample-org-00/issues/xxx" # Optional
    FollowUp       = "1970-01-01"                                  # Optional
    FollowUpReason = "https://github.com/sample-org-00/issues/xxx" # Optional
  }
}

module "target" {
  # When you use this module, replace the source with a version pinned reference
  # eg. git@github.com:undefined-io/terraform-aws-s3-state-for-organization?ref=1.0.0
  source = "../../"

  # this module requires two providers since the main and backup state buckets
  #   are meant to be located in different regions.
  providers = {
    aws.primary   = aws.use1
    aws.secondary = aws.usw2
  }
  name = "${local.name}-${local.id}"
  tags = local.tags

  # The permission sets that should be able to assume role to access the state
  # NOTE: These don't have to be valid or existing permission-sets, since this
  #   is evaluated as a condition
  permission_set_name_list = [
    "name1",
    "name2"
  ]
  # NOTE: These have to be existing and valid roles
  aws_principal_arn = [
    aws_iam_role.this["temp"].arn
  ]

  iac_principal_arn = aws_iam_role.this["iac"].arn
}

output "all" {
  value = module.target
}

resource "aws_iam_role" "this" {
  provider    = aws.use1
  for_each    = toset(["iac", "temp"])
  name_prefix = "${local.name}-${local.id}-${each.key}-"
  tags        = local.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "000000000000"
        }
      },
    ]
  })
}
