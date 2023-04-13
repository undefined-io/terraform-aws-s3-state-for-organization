terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.27"
      configuration_aliases = [
        aws.primary,
        aws.secondary,
      ]
    }
  }
}
