# Set this to true to run Terraform manually
export TF_VAR_run_manually := true
export TF_VAR_cloudflare_api_token := $(shell pass show sysadmin/services/cloudflare/pytorch/api_token)
export TF_VAR_cloudflare_discuss_tunnel_secret := $(shell pass show sysadmin/services/cloudflare/pytorch/discuss_tunnel_secret)

export TF_VAR_datadog_api_key = $(shell pass show sysadmin/keys/datadog/pytorch/apikey)
export TF_VAR_datadog_app_key = $(shell pass show sysadmin/keys/datadog/pytorch/appkeys/terraform)

export DD_API_KEY = $(shell pass sysadmin/keys/datadog/pytorch/apikey)
export DD_APP_KEY=  $(shell pass sysadmin/keys/datadog/pytorch/appkeys/terraform)

export PROJECT_NAME 	   ?= "pytorch"

.PHONY: error init refresh plan apply clean all test
error:
	@echo "Valid targets: init refresh plan apply clean"
	@exit 2

# The first one of these runs when called explicitly, the second automatically
# when the directory is missing.
# XXX: for CI/CD we'd need to run this every time (or call it every time)
init:
	tofu init -backend-config="role_arn=arn:aws:iam::391835788720:role/lfit-sysadmins-mfa" \
		-backend-config="bucket=opentofu-state-${PROJECT_NAME}" \
		-backend-config="dynamodb_table=opentofu-state-${PROJECT_NAME}" \
		-upgrade=true
.terraform:
	tofu init -backend-config="role_arn=arn:aws:iam::391835788720:role/lfit-sysadmins-mfa" \
		-backend-config="bucket=opentofu-state-${PROJECT_NAME}" \
		-backend-config="dynamodb_table=opentofu-state-${PROJECT_NAME}" \
		-upgrade=true

refresh:
	tofu refresh

plan: .terraform
	pass git pull --rebase
	tofu get --update
	tofu plan -out tofu.tfplan $(ARGS)

validate: init
	tofu validate

import:
	tofu import $(ARGS)

# This intentionally does NOT depend on tofu.tfplan because make and apply
# need to be separate make invocations. This target is just for convenience;
# running "tofu apply" directly is fine.
apply:
	tofu apply tofu.tfplan

clean:
	rm -vf tofu.tfplan
test:
	tofu fmt
	tflint
all:
	@echo "This is a checkmake required phony target"
# vim: ai noet ts=4 sw=4
