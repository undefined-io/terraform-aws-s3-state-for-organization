data "aws_region" "primary" { provider = aws.primary }
data "aws_caller_identity" "primary" { provider = aws.primary }
data "aws_partition" "primary" { provider = aws.primary }
locals {
  aws_primary = {
    region     = data.aws_region.primary.name
    account_id = data.aws_caller_identity.primary.account_id
    dns_suffix = data.aws_partition.primary.dns_suffix
    partition  = data.aws_partition.primary.partition
  }
}
data "aws_region" "secondary" { provider = aws.secondary }
data "aws_caller_identity" "secondary" { provider = aws.secondary }
data "aws_partition" "secondary" { provider = aws.secondary }
locals {
  aws_secondary = {
    region     = data.aws_region.secondary.name
    account_id = data.aws_caller_identity.secondary.account_id
    dns_suffix = data.aws_partition.secondary.dns_suffix
    partition  = data.aws_partition.secondary.partition
  }
}

locals {
  # S3 related variables
  main_name   = "${var.name}-main"
  backup_name = "${var.name}-backup"

  # - Convert the permission set name to the wildcard ARN
  # - Due to permission sets being org wide unique, we don't care about the account_id
  #   part of the arn.
  # arn:aws:iam::*:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_ROLENAME_a10a375889168e19
  # arn:aws:iam::*:role/aws-reserved/sso.amazonaws.com/REGION/AWSReservedSSO_ROLENAME_a10a375889168e19
  permission_set_arn_list = [
    for v in var.permission_set_name_list
    : "arn:aws:iam::*:role/aws-reserved/sso.amazonaws.com*/AWSReservedSSO_${v}_*"
  ]
}
