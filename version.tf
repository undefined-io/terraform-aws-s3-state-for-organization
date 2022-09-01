### OVERVIEW BEGIN
# Refer to the 'Module Versioning' section in the README for more information
### OVERVIEW END
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.27"

      # The template recommendation is to write your module with a provider
      #   that is supplied when the module is instantiated, vs using the
      #   default provider.
      # If you really need to use the default provider only, then please
      #   the configuration_aliases below, and from anything in the examples/
      #   directory.
      configuration_aliases = [
        aws.primary,
      ]
    }
  }
}
