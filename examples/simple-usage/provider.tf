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

locals {
  default_tags = {
    "ManagedBy"   = "Terraform"
    "Environment" = "Test"
  }
}

provider "aws" {
  max_retries         = 2
  region              = "us-east-1"
  allowed_account_ids = ["198604607953"]

  default_tags {
    tags = local.default_tags
  }
  #assume_role {
  #  role_arn = "arn:aws:iam::198604607953:role/infrastructure-as-code-admin"
  #}
}

provider "aws" {
  alias               = "usw2"
  max_retries         = 2
  region              = "us-west-2"
  allowed_account_ids = ["198604607953"]

  default_tags {
    tags = local.default_tags
  }
  #assume_role {
  #  role_arn = "arn:aws:iam::198604607953:role/infrastructure-as-code-admin"
  #}
}
