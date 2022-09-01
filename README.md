[![unit-test](../../actions/workflows/unit-test.yml/badge.svg)](../../actions/workflows/unit-test.yml)

# `terraform-aws-testable-module`

A template repository for Terraform modules where AWS is the primary provider.

- Comes with support for unit tests that run in GitHub actions
- Sample Spacelift module test config

## Getting Started (Do this before writing code)

- [Create a new repository](https://github.com/undefined-io/terraform-aws-testable-module/generate) from the template repository.

  > If this module requires access to other private repository modules in the via SSH, please add the `TF_TESTABLE_MODULE_SSH_KEY`  secret to your repository secrets.

- (*Suggestion*) Add `terraform` and `module` as topics in the "About" section of the repository

  > By following this standard, it's easy to later locate all the modules in GitHub

- :heavy_exclamation_mark: Review all the default choices in the the `version.tf` file and adjust them as needed.

  > The `version.tf` file directly impacts the tests in the `examples/` directory, and changes might be needed there before all the tests will pass.

- (*Optional*) Change the matrix to match what you plan on supporting in the `.github/workflows/module-test.yaml` file

- (Optional) If you plan on running the GitHub Action locally, install [nektos/act](https://github.com/nektos/act).  More information on that is [here]().

- Commit the initial changes to make sure the GitHub action succeeds with the new repo.

## Testing Overview

To better understand some of the terminology, I highly recommend at least reading over [this blog post](https://www.hashicorp.com/blog/testing-hashicorp-terraform) explaining some of the basic terraform test concepts, such as what a **unit test** is.

Our current system is focused on the following.

- Local **Unit Tests**

  These use the *currently installed version* of Terraform, and do a basic sanity on the module to make sure it would run at all.

- Automated **Unit Tests** via GitHub actions.

  These are fired automatically on commit to GitHub, but can also be executed locally.  They run against a matrix of Terraform versions to make establish that versions of Terraform this module could support.

- Locally initiated **Integration Tests**.

## 1. Local Unit Tests

- Uses locally installed `terraform` to validate `.tf` files.
- DOES NOT create any resources

### Requirements

- Terraform

### Steps

```bash
make unit-test
```

## 2. Local Automated Unit Tests

- Run the Unit Tests via the GitHub action locally.

### Requirements

- Terraform
- [nektos/act](https://github.com/nektos/act)

### Steps

```bash
# a module with only public or no dependencies on other modules
make action

# if you need to test a module with private dependencies
export TF_TESTABLE_MODULE_SSH_KEY=$(</path/to/ssh/key/with/github/access)
make action
```

## 3. Locally Initiated Integration Tests

### Full Test

The test is a basic `terraform init/apply/destroy` using local state.

```bash
# provide environment variables for the AWS provider
# , then run...
make full-test
```

### Partial Test

When iterating on code, it can sometimes be useful not to destroy.  In that case, just call the individual operations.

```bash
# if you want to just run a plan
make plan
# create/update the resources
make apply
# do more dev
make apply
# ... (repeat until done)

# destroy only
make destroy
```

## Notes

### Existing Module Usage Helper Script

```bash
# Run in the root of aws-infrastructure
grep -ire '[?]ref=' \
  --exclude-dir=.terraform \
  --no-filename . \
  | sed -e 's|git@github.com:||' -e 's|git::https://github.com/||' \
  | awk -F' = ' '{a[$2]++} END{for (i in a) print i, a[i]}' \
  | sort
```

### Updating to the latest version of the template

(*Optional*) This setup will allow you to easily merge updates to the template at a later point.  By doing this now, the later merges will be significantly easier.

```bash
git remote add template git@github.com:undefined-io/terraform-aws-testable-module.git
git fetch --all
git merge --no-commit --allow-unrelated-histories template/main
# resolve the merge conflicts
git add -A
git commit
```

## Module Versioning

This pertains to the **`version.tf`** file at the root of the module.  If you need guidance, reach out to the SRE team for advice.

### Upper Bounds (In General)

With modules, it's highly recommended not to set an upper bound for versions, as it leads to situations where a module can no longer be used, because the upper bound unnecessarily forces the module to be upgraded, even though it would still function in higher versions.

Historically, we've had more problems with modules that had a specific upper bound for no reason, than with modules that had no upper bounds.

### Terraform

Setting a proper lower bound, to make sure the module is safe and can function at all is essential.  In terms up upper bounds, support as many versions as possible here, so the module can actually get good use.  It's really up to the consumer to define these constraints more than the module.  To cover different versions of Terraform, matrix in the provided GitHub action will help you.

### AWS

Focus on the target audience. For modules, compatibility is more important that being completely up to date.  When writing a module, it makes sense to really find a good middle ground for provider lower bounds.
