
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 4.27.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1"
    }
  }
}

provider "aws" {
  max_retries         = 2 # default is 25
  region              = "us-east-1"
  allowed_account_ids = ["198604607953"] # sample account

  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags
  # Common default tags
  default_tags {
    tags = {
      "ManagedBy"   = "Terraform"
      "Environment" = "Test"
    }
  }

  # Use this if your workflow supports roles
  #assume_role {
  #  role_arn = "arn:aws:iam::000000000000:role/adequate-permission-role"
  #}
}
