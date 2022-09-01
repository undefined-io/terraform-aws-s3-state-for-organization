variable "name" {
  type        = string
  description = <<-DOC
  'name' will at least in part be assigned to most resources
  DOC
  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "The 'name' cannot be empty."
  }
}

variable "tags" {
  type    = map(string)
  default = {}
}

# Since Terraform does not allow validations across variables, just be
#   aware that one of the two following variables needs to contain a value.
#   - permission_set_name_list
#   - aws_principal_arn
variable "permission_set_name_list" {
  type        = list(string)
  default     = []
  description = <<-DOC
  List of SSO PermissionSet Names with access to the state bucket
  DOC
  validation {
    condition     = length(var.permission_set_name_list) >= 0
    error_message = "The 'permission_set_name_list' cannot be null."
  }
}

# TODO: exclude *
variable "aws_principal_arn" {
  type        = list(string)
  default     = []
  description = <<-DOC
  Specific principal ARN that should be able to assume role
  DOC
  validation {
    condition     = !contains(var.aws_principal_arn, "*")
    error_message = "The 'aws_principal_arn' cannot contain '*' entries."
  }
}
