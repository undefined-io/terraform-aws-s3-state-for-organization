resource "random_string" "sample" {
  special = false
  upper   = false
  length  = 4
}

locals {
  id = random_string.sample.id
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
    aws.primary   = aws
    aws.secondary = aws.usw2
  }
  name = "tassfo-test-${local.id}"
  tags = local.tags

  # The permission sets that should be able to assume role to access the state
  permission_set_name_list = [
    "admin",
  ]
}

output "all" {
  value = module.target
}
