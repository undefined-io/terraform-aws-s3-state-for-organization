variable "name" {
  type = string
  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "The 'name' cannot be empty."
  }
  description = <<-DOC
  'name' will at least in part be assigned to most resources
  DOC
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "permission_set_name_list" {
  type        = list(string)
  default     = []
  description = <<-DOC
  List of SSO PermissionSet Names with access to the state bucket
  DOC
}
