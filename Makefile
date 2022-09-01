SHELL := /usr/bin/env bash -euo pipefail -c

#https://www.gnu.org/software/make/manual/make.html
.NOTPARALLEL:
.EXPORT_ALL_VARIABLES:

AWS_RETRY_MODE=standard
AWS_MAX_ATTEMPTS=1
TF_IN_AUTOMATION=1

main:
	@echo "action    : Simulate github action locally"
	@echo "aws-creds : Check if AWS access is valid"
	@echo "clean     : Cleanup any temp files"
	@echo "plan      : Plan after unit-test"
	@echo "apply     : Apply after unit-test"
	@echo "destroy   : Destroy all resources"
	@echo "full-test : Applies and destroys all resources"
	@echo "unit-test : Purely local full syntax validation"
	@true

clean:
	rm -f .terraform.lock.hcl
	rm -rf ./.terraform

plan: clean
	@terraform version \
		&& cd "examples/simple-usage" \
		&& terraform fmt --check \
		&& terraform init \
		&& terraform validate \
		&& terraform plan

unit-test: clean
	@terraform version \
		&& cd "examples/simple-usage" \
		&& terraform fmt --check \
		&& terraform init \
		&& terraform validate

full-test: clean unit-test
	# why 2 times?  this is to make sure the module doesn't have
	# any unexpected changes the second time around.
	@cd "examples/simple-usage" \
		&& (terraform apply -auto-approve \
			&& terraform apply -auto-approve) \
		|| true \
		;	terraform destroy -auto-approve

aws-creds:
	aws --no-cli-pager sts get-caller-identity

apply: aws-creds unit-test
	@cd "examples/simple-usage" \
		&& terraform apply -auto-approve

destroy: aws-creds
	@cd "examples/simple-usage" \
		&& terraform destroy -auto-approve

action:
	@act -s TF_TESTABLE_MODULE_SSH_KEY -C . \
		|| echo -e "\n:: NOTE: If act failed due to private repo issues, TF_TESTABLE_MODULE_SSH_KEY needs to be set per README."

.PHONY: main full-test apply destroy unit-test clean aws-creds plan action
