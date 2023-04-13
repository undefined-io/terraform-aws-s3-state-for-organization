terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
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
  max_retries = 2
  region      = "invalid"
  access_key  = "invalid"
  secret_key  = "invalid"
  token       = "invalid"
}

provider "aws" {
  alias               = "use1"
  max_retries         = 2
  region              = "us-east-1"
  allowed_account_ids = ["000000000000"]

  default_tags { tags = local.default_tags }
}

provider "aws" {
  alias               = "usw2"
  max_retries         = 2
  region              = "us-west-2"
  allowed_account_ids = ["000000000000"]

  default_tags { tags = local.default_tags }
}
