# Define DNSIMPLE api credentials globally here to use with all aws accounts we have
export DNSIMPLE_TOKEN := $(shell pass show sysadmin/services/dnsimple/thelinuxfoundation/apikey)
export DNSIMPLE_ACCOUNT := 89897
export TF_VAR_datadog_api_key := $(shell pass show sysadmin/keys/datadog/lfit/apikey)
export TF_VAR_datadog_app_key := $(shell pass show sysadmin/keys/datadog/lfit/appkeys/terraform)
export TF_VAR_run_manually := true
export TF_VAR_gitlab_token := $(shell pass show sysadmin/services/gitlab/linuxfoundation/lfgitlabbot/personal-access-token)
export PROJECT_NAME			  ?= "!!Set Project name!!"

.PHONY: error init refresh plan apply clean
error:
	@echo "Valid targets: init refresh plan apply clean"
	@exit 2

# The first one of these runs when called explicitly, the second automatically
# when the directory is missing.
# XXX: for CI/CD we'd need to run this every time (or call it every time)
init:
	tofu init -backend-config="role_arn=arn:aws:iam::450177423209:role/lfit-sysadmins-mfa" \
		-backend-config="bucket=lfx-terraform-state-${PROJECT_NAME}" \
		-backend-config="dynamodb_table=lfx-terraform-state-${PROJECT_NAME}" \
		-upgrade=true
.tofu:
	tofu init -backend-config="role_arn=arn:aws:iam::450177423209:role/lfit-sysadmins-mfa" \
		-backend-config="bucket=lfx-terraform-state-${PROJECT_NAME}" \
		-backend-config="dynamodb_table=lfx-terraform-state-${PROJECT_NAME}" \
		-upgrade=true

refresh:
	tofu refresh

plan: .tofu
	pass git pull --rebase
	tofu get --update
	tofu plan -out tofu.tfplan $(ARGS)

validate: init
	tofu validate

import:
	tofu import $(ARGS)

apply:
	tofu apply tofu.tfplan

clean:
	rm -vf tofu.tfplan

# vim: ai noet ts=4 sw=4
