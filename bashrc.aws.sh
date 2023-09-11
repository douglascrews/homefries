script_echo AWS setup...

alias awscli='aws --cli-auto-prompt'
alias aws_vpc_list='awsls --profiles dougcrews --attributes tags,cidr_block aws_vpc'
alias aws_all_list='awsls --profiles dougcrews --attributes tags,cidr_block aws_*'

aws_assume_role() {
	# help
	[[ "${1}" == "--help" ]] || [[ "${1}" == "-h" ]] || [[ -z "${1}" ]] && { \
		echo -e "${FUNCNAME}()\n\t role-ARN ARN for the Role to assume\n"; \
		return 0; \
	}
	local role_arn=$1;
	[[ -z ${role_arn} ]] && { echo 'Role ARN is required'; return 0; }
	echo "Params passed: ${role_arn}"
	export ROLE_CREDENTIALS=$(aws sts assume-role --role-arn %1 --role-session-name AWSCLI-Session --output json)
	export AWS_ACCESS_KEY_ID=$(echo $ROLE_CREDENTIALS | jq .Credentials.AccessKeyId | sed 's/"//g')
	export AWS_SECRET_ACCESS_KEY=$(echo $ROLE_CREDENTIALS | jq .Credentials.SecretAccessKey | sed 's/"//g')
	export AWS_SESSION_TOKEN=$(echo $ROLE_CREDENTIALS | jq .Credentials.SessionToken | sed 's/"//g')
}

aws_sso_account ()
{
	export AWS_ACCOUNT=$(aws sts get-caller-identity --query "Account" 2> /dev/null);
	echo ${AWS_ACCOUNT}
}