data "aws_region" "current" {
  provider = aws.primary
}
data "aws_caller_identity" "current" {
  provider = aws.primary
}
data "aws_partition" "current" {
  provider = aws.primary
}
locals {
  aws_primary = {
    region     = data.aws_region.current.name
    account_id = data.aws_caller_identity.current.account_id
    dns_suffix = data.aws_partition.current.dns_suffix
    partition  = data.aws_partition.current.partition
  }
}
