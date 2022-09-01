# name and tags are common variables but don't need to exist

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
