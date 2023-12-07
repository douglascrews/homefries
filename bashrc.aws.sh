script_echo AWS setup...

alias awscli='aws --cli-auto-prompt'

aws_assume_role() {
	# help
	[[ "${args[@]}" == "--help" ]] || [[ "${args[@]}" == "-h" ]] || [[ -z "${1}" ]] && { \
		echo -e "${FUNCNAME}()"; \
		echo -e "\n\t role_arn ARN for the Role to assume"; \
		echo -e "\n\t [profile] AWS profile to assume (default \"service\")"; \
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

aws_eks_list_clusters() {
	aws --profile ${1:-default} eks list-clusters | jq ".clusters[]"
}

aws_elb_list_instances() {
	aws --profile ${1:-default} elb describe-load-balancers | jq ".LoadBalancerDescriptions[].LoadBalancerName"
}

aws_rds_list_instances() {
	aws rds describe-db-instances --profile ${1:-default} | jq ".DBInstances[].DBInstanceIdentifier"
}

aws_rds_list_instances_details() {
	aws rds describe-db-instances --profile ${1:-default} | jq '.DBInstances[] | "\(.DBInstanceIdentifier) \(.DBInstanceClass) \(.Engine) \(.EngineVersion) \(.Endpoint.Address):\(.Endpoint.Port) \(.AvailabilityZone) \(.AllocatedStorage)GB"'
}

aws_rds_list_snapshots() {
	aws rds describe-db-snapshots --profile ${1:-default} | jq ".DBSnapshots[].DBSnapshotIdentifier"
}

aws_route53_list_hosted_zones() {
	aws --profile ${1:-default} route53 list-hosted-zones | jq ".HostedZones[].Name"
}

aws_sso_account() {
	export AWS_ACCOUNT=$(aws sts get-caller-identity --profile ${1:-service} --query "Account" 2> /dev/null);
	echo ${AWS_ACCOUNT}
}

aws_vpc_list() {
	awsls --profiles ${1:-dougcrews} --attributes tags,cidr_block aws_vpc
}

aws_all_list() {
	awsls --profiles ${1:-dougcrews} --attributes tags,cidr_block aws_*
}
