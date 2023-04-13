# terraform-aws-state-storage

- A main S3 State Bucket that requires encrypted communication
- A backup S3 State Bucket (which can be in a different region)
- Replication between the main and backup bucket
- A role with limited access to manipulate state in the main S3 bucket, which can be assumed by specific AWS principals or SSO Permission-Sets.
- DynamoDB State locking according to Terraform `backend "s3"` specs

## Terraform Syntax

This is a sample snippet of what would be added to your Terraform stack in order to access state using this module setup.

```terraform
terraform {
  backend "s3" {
    role_arn       = "arn:aws:iam::000000000000:role/state-bucket-test-s2r4-state"
    bucket         = "state-bucket-test-s2r4-main"
    dynamodb_table = "state-bucket-test-s2r4-locks"
    key            = "example/prototype/test"
    region         = "us-east-1"
    encrypt        = true
    max_retries    = 2
  }
}
```

Important thing to note about the block above, is that the credentials used to assume the `role_arn` are pulled from the environment.

Blocks like the following, **DO NOT** have any relation to the above, meaning that the `aws` provider is not needed in order to access AWS S3 state.

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

Likewise, the credentials in the block below are also not related to the `backend "s3"` block.

```terraform
provider "aws" {
  region      = "someregion"
  access_key  = "123"
  secret_key  = "456"
  token       = "789"
}
```

## DynamoDB locking

For example, a stack with the name `example/prototype/test` will generate a DynamoDB entry with `LockID` being `state-bucket-test-s2r4-main/example/prototype/test` and the following content.

`LockID` is a standard used by the S3/DynamoDB Terraform [backend](https://www.terraform.io/language/settings/backends/s3#dynamodb-state-locking).

```json
{
  "ID": "15c87bd1-b189-4cb5-359d-746c71e3068e",
  "Operation": "OperationTypeApply",
  "Info": "",
  "Who": "username@pop-os",
  "Version": "1.2.7",
  "Created": "2022-08-25T04:08:31.335995976Z",
  "Path": "state-bucket-test-s2r4-main/example/prototype/test"
}
```

### What do I do if the statefile lock was not released?

```bash
# The ID would show up in the error message you get when trying to run terraform
terraform force-unlock <ID>
```

> **PLEASE be sure that the statefile lock was yours!**

Sample Error:

```text
Acquiring state lock. This may take a few moments...
╷
│ Error: Error acquiring the state lock
│ 
│ Error message: ConditionalCheckFailedException: The conditional request failed
│ Lock Info:
│   ID:        6b0b048e-5cf4-c88b-667e-4522ccf65659
│   Path:      state-bucket-test-s2r4-main/example/prototype/test
│   Operation: OperationTypeApply
│   Who:       phadviger@pop-os
│   Version:   1.2.7
│   Created:   2022-09-08 10:50:46.24286514 +0000 UTC
│   Info:      
```
