# terraform-aws-s3-state-for-organization

## DynamoDB locking

For example, a stack with the name `aws/test/stack` will generate a DynamoDB entry with `LockID` being `tassfo-test-s2r4-main/aws/test/stack` and the following content.

`LockID` is a standard used by the S3/DynamoDB Terraform [backend](https://www.terraform.io/language/settings/backends/s3#dynamodb-state-locking).

> TODO: See if the "Who" can be better

```json
{
  "ID": "15c87bd1-b189-4cb5-359d-746c71e3068e",
  "Operation": "OperationTypeApply",
  "Info": "",
  "Who": "username@pop-os",
  "Version": "1.2.7",
  "Created": "2022-08-25T04:08:31.335995976Z",
  "Path": "tassfo-test-s2r4-main/aws/test/stack"
}
```

## Terraform Syntax

```terraform
terraform {
  backend "s3" {
    role_arn       = "arn:aws:iam::988857891049:role/tassfo-test-s2r4-state"
    bucket         = "tassfo-test-s2r4-main"
    dynamodb_table = "tassfo-test-s2r4-locks"
    key            = "aws/test/stack"
    region         = "us-east-1"
    encrypt        = true
    max_retries    = 2
  }
}
```

What's important here, is that the credentials can, but generally are not passed in here, and are pulled from the environment instead.  Also it **DOES NOT** rely on the following being present (for the state file management itself).

```terraform
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.27"
    }
  }
}
```

