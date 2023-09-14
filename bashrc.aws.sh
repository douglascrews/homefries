script_echo AWS setup...

alias awscli='aws --cli-auto-prompt'
alias aws_vpc_list='awsls --profiles dougcrews --attributes tags,cidr_block aws_vpc'
alias aws_all_list='awsls --profiles dougcrews --attributes tags,cidr_block aws_*'

aws_assume_role() {
	# help
	[[ "${1}" == "--help" ]] || [[ "${1}" == "-h" ]] || [[ -z "${1}" ]] && { \
		echo -e "${FUNCNAME}()\n\t role_arn ARN for the Role to assume\n\t [profile] AWS profile to assume (default \"service\")"; \
		return 0; \
	}
	local role_arn="$1";
	local aws_profile="${2:-service}"
	[[ -z "${role_arn}" ]] && { echo 'Role ARN is required'; return 0; }
	echo "Assuming role ${role_arn} in profile ${aws_profile}"
	export ROLE_CREDENTIALS=$(aws sts assume-role --profile ${aws_profile} --role-arn "${role_arn}" --role-session-name AWSCLI-Session --output json)
	export AWS_ACCESS_KEY_ID=$(echo $ROLE_CREDENTIALS | jq .Credentials.AccessKeyId | sed 's/"//g')
	export AWS_SECRET_ACCESS_KEY=$(echo $ROLE_CREDENTIALS | jq .Credentials.SecretAccessKey | sed 's/"//g')
	export AWS_SESSION_TOKEN=$(echo $ROLE_CREDENTIALS | jq .Credentials.SessionToken | sed 's/"//g')
	( [[ -n "${AWS_ACCESS_KEY_ID}" ]] && [[ -n "${AWS_SECRET_ACCESS_KEY}" ]] && [[ -n "${AWS_SESSION_TOKEN}" ]] && echo "Success!" ) || echo "Failed."
}

aws_sso_account ()
{
	export AWS_ACCOUNT=$(aws sts get-caller-identity --query "Account" 2> /dev/null);
	echo ${AWS_ACCOUNT}
}