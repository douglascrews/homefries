script_echo AWS setup...

alias awscli='aws --cli-auto-prompt'
alias aws_profiles="grep '^\[profile ' ~/.aws/config | sed 's/\[profile \(.*\)\]/\1/'"

aws_sso_login() {
	${ECHODO} aws --profile ${1:-service} sso login
}

aws_sso_account() {
	export AWS_ACCOUNT=$(aws sts get-caller-identity --profile ${1:-service} --query "Account" 2> /dev/null);
	echo ${AWS_ACCOUNT}
}

aws_sso_required() {
	([[ -n "$(aws_sso_account)" ]] || aws_sso_login) && aws_sso_account
}

aws_profile_account() {
	aws --profile ${1:-${AWS_PROFILE:-dba}} ec2 describe-security-groups --query 'SecurityGroups[0].OwnerId' --output text
}

aws_assume_role() {
	# help
	[[ "${*}" =~ --help ]] || [[ "${#}" == 0 ]] && { \
		echo -e "${FUNCNAME} role_arn [profile]"; \
		echo -e "\t role_arn \tAWS role to assume"; \
		echo -e "\t [profile] AWS profile to assume (default \"service\")"; \
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

# Execute a command for all known AWS profiles; example: "aws_all aws_rds_list_instances"
aws_all() {
	for profile in $(aws_profiles); do echodo ${*} ${profile}; done
}

aws_ecr_get_password() {
   aws --profile ${1:-service} ecr get-login-password
}

aws_eks_list_clusters() {
	[[ "${*}" =~ --help ]] || [[ "${#}" == 0 ]] && { \
		echo -e "${FUNCNAME} profile [--raw]"; \
		echo -e "\t profile \tAWS profile to assume"; \
		echo -e "\t [--raw] \tRaw output from AWS CLI"; \
		return 0; \
	}
	aws_sso_required
	local JQ_QUERY='.clusters[]'
	[[ "${*}" =~ --raw ]] && JQ_QUERY='.'
	aws --profile ${1} eks list-clusters | jq "${JQ_QUERY}"
}

aws_eks_describe_cluster() {
	[[ "${*}" =~ --help ]] || [[ "${#}" == 0 ]] && { \
		echo -e "${FUNCNAME} profile cluster_name [--raw]"; \
		echo -e "\t profile \tAWS profile to assume"; \
		echo -e "\t cluster_name \tCluster name"; \
		echo -e "\t [--raw] \tRaw output from AWS CLI"; \
		return 0; \
	}
	aws_sso_required
	local JQ_QUERY='.cluster | "name=\(.name) endpoint=\(.endpoint) cidr=\(.kubernetesNetworkConfig.serviceIpv4Cidr) status=\(.status)"'
	[[ "${*}" =~ --raw ]] && JQ_QUERY='.'
	aws --profile ${1} eks describe-cluster --name ${2:-"ERROR_cluster-name_undefined"} | jq "${JQ_QUERY}"
}

aws_eks_describe_clusters() {
	[[ "${*}" =~ --help ]] || [[ "${#}" == 0 ]] && { \
		echo -e "${FUNCNAME} profile"; \
		echo -e "\t profile \tAWS profile to assume"; \
		return 0; \
	}
	aws_sso_required
	for kluster in $(aws_eks_list_clusters ${1}); do echodo aws_eks_describe_cluster $kluster; done
}

aws_elasticache_list_clusters() {
	[[ "${*}" =~ --help ]] || [[ "${#}" == 0 ]] && { \
		echo -e "${FUNCNAME} profile [--raw]"; \
		echo -e "\t profile \tAWS profile to assume"; \
		echo -e "\t [--raw] \tRaw output from AWS CLI"; \
		return 0; \
	}
	aws_sso_required
	local JQ_QUERY='.CacheClusters[] | "id=\(.CacheClusterId) ARN=\(.ARN) engine=\(.Engine) \(.EngineVersion) size=\(.CacheNodeType)"'
	[[ "${*}" =~ --raw ]] && JQ_QUERY='.'
   aws elasticache describe-cache-clusters --profile ${1} | jq -c -C -S -r "${JQ_QUERY}"
}

aws_elb_list_instances() {
	[[ "${*}" =~ --help ]] || [[ "${#}" == 0 ]] && { \
		echo -e "${FUNCNAME} profile [--raw]"; \
		echo -e "\t profile \tAWS profile to assume"; \
		echo -e "\t [--raw] \tRaw output from AWS CLI"; \
		return 0; \
	}
	aws_sso_required
	local JQ_QUERY='.LoadBalancerDescriptions[].LoadBalancerName'
	[[ "${*}" =~ --raw ]] && JQ_QUERY='.'
	aws --profile ${1} elb describe-load-balancers | jq "${JQ_QUERY}"
}

aws_lambda_list_functions() {
	[[ "${*}" =~ --help ]] || [[ "${#}" == 0 ]] && { \
		echo -e "${FUNCNAME} profile [--raw]"; \
		echo -e "\t profile \tAWS profile to assume"; \
		echo -e "\t [--raw] \tRaw output from AWS CLI"; \
		return 0; \
	}
	aws_sso_required
	local JQ_QUERY='.Functions[] | "\(.FunctionName) \(.Runtime) \(.Handler) \(.Version) \(.FunctionArn) \(.Role)"'
	[[ "${*}" =~ --raw ]] && JQ_QUERY='.'
	aws --profile ${1} lambda list-functions | jq "${JQ_QUERY}"
}

aws_lambda_invoke_function() {
	[[ "${*}" =~ --help ]] || [[ "${#}" == 0 ]] && { \
		echo -e "${FUNCNAME} profile func_name [payload]"; \
		echo -e "\t profile \tAWS profile to assume"; \
		echo -e "\t func_name \tFunction name to invoke"; \
		echo -e "\t [payload] \tFunction payload in JSON format"; \
		return 0; \
	}
	aws_sso_required
	local OUTPUT=$(aws --profile ${1} lambda invoke --function-name ${2} --log-type Tail -)
	echo ${OUTPUT} | jq ".StatusCode"
	echo ${OUTPUT} | jq ".LogResult" | sed -e 's/"//g' | base64 --decode
}

aws_rds_describe_instances() {
	[[ "${*}" =~ --help ]] || [[ "${#}" == 0 ]] && { \
		echo -e "${FUNCNAME} profile [--raw]"; \
		echo -e "\t profile \tAWS profile to assume"; \
		echo -e "\t [--raw] \tRaw output from AWS CLI"; \
		return 0; \
	}
	aws_sso_required
	local JQ_QUERY=''
	[[ "${*}" =~ --raw ]] && JQ_QUERY='.'
	aws rds describe-db-instances --profile ${1} | jq "${JQ_QUERY}"
}

aws_rds_list_instances() {
	[[ "${*}" =~ --help ]] || [[ "${#}" == 0 ]] && { \
		echo -e "${FUNCNAME} profile [--raw]"; \
		echo -e "\t profile \tAWS profile to assume"; \
		echo -e "\t [--raw] \tRaw output from AWS CLI"; \
		return 0; \
	}
	aws_sso_required
	local JQ_QUERY='.DBInstances[] | "\(.DBInstanceArn) \(.DBInstanceClass) \(.Engine)\(.EngineVersion) \(.Endpoint.Address):\(.Endpoint.Port)"'
	[[ "${*}" =~ --raw ]] && JQ_QUERY='.'
	aws rds describe-db-instances --profile ${1} | jq "${JQ_QUERY}"
}

aws_rds_describe_snapshots() {
	[[ "${*}" =~ --help ]] || [[ "${#}" == 0 ]] && { \
		echo -e "${FUNCNAME} profile [snapshot_type] [--raw]"; \
		echo -e "\t profile \tAWS profile to assume"; \
		echo -e "\t [snapshot_type] \tSnapshot type: automated,manual,shared,public,awsbackup; default ALL"; \
		echo -e "\t [--raw] \tRaw output from AWS CLI"; \
		return 0; \
	}
	aws_sso_required
	[[ "${2}" == "automated" ]] || [[ "${2}" == "manual" ]] || [[ "${2}" == "shared" ]] || [[ "${2}" == "public" ]] || [[ "${2}" == "awsbackup" ]] && local SNAPSHOT_TYPE_PARAM=--snapshot-type && local SNAPSHOT_TYPE_VALUE=${2}
	local JQ_QUERY='.DBSnapshots[] | "\(.DBSnapshotIdentifier) \(.Engine) \(.EngineVersion) \(.Status) \(.SnapshotType) \(.AvailabilityZone) \(.SnapshotCreateTime)"'
	[[ "${*}" =~ --raw ]] && JQ_QUERY='.'
	aws rds describe-db-snapshots --profile ${1} ${SNAPSHOT_TYPE_PARAM} ${SNAPSHOT_TYPE_VALUE} | jq "${JQ_QUERY}"
}

aws_rds_list_snapshots() {
	[[ "${*}" =~ --help ]] || [[ "${#}" == 0 ]] && { \
		echo -e "${FUNCNAME} profile [snapshot_type] [--raw]"; \
		echo -e "\t profile \tAWS profile to assume"; \
		echo -e "\t [snapshot_type] \tSnapshot type: automated,manual,shared,public,awsbackup; default ALL"; \
		echo -e "\t [--raw] \tRaw output from AWS CLI"; \
		return 0; \
	}
	aws_sso_required
	[[ "${2}" == "automated" ]] || [[ "${2}" == "manual" ]] || [[ "${2}" == "shared" ]] || [[ "${2}" == "public" ]] || [[ "${2}" == "awsbackup" ]] && local SNAPSHOT_TYPE_PARAM=--snapshot-type && local SNAPSHOT_TYPE_VALUE=${2}
	local JQ_QUERY='.DBSnapshots[].DBSnapshotArn'
	[[ "${*}" =~ --raw ]] && JQ_QUERY='.'
	aws rds describe-db-snapshots --profile ${1} ${SNAPSHOT_TYPE_PARAM} ${SNAPSHOT_TYPE_VALUE} | jq "${JQ_QUERY}"
}

aws_route53_list_hosted_zones() {
	[[ "${*}" =~ --help ]] || [[ "${#}" == 0 ]] && { \
		echo -e "${FUNCNAME} profile [--raw]"; \
		echo -e "\t profile \tAWS profile to assume"; \
		echo -e "\t [--raw] \tRaw output from AWS CLI"; \
		return 0; \
	}
	aws_sso_required
	local JQ_QUERY='.HostedZones[].Name'
	[[ "${*}" =~ --raw ]] && JQ_QUERY='.'
	aws --profile ${1} route53 list-hosted-zones | jq "${JQ_QUERY}"
}

aws_vpc_list() {
#	awsls --profiles ${1:-dougcrews} --attributes tags,cidr_block aws_vpc
	[[ "${*}" =~ --help ]] || [[ "${#}" == 0 ]] && { \
		echo -e "${FUNCNAME} profile [--raw]"; \
		echo -e "\t profile \tAWS profile to assume"; \
		echo -e "\t [--raw] \tRaw output from AWS CLI"; \
		return 0; \
	}
	aws_sso_required
	local JQ_QUERY='.Vpcs[] | "id=\(.VpcId) cidr=\(.CidrBlock) owner=\(.OwnerId) default=\(.IsDefault)"'
	[[ "${*}" =~ --raw ]] && JQ_QUERY='.'
	aws ec2 describe-vpcs --profile ${1} | jq -r "${JQ_QUERY}"
}

aws_all_list() {
	[[ "${*}" =~ --help ]] || [[ "${#}" == 0 ]] && { \
		echo -e "${FUNCNAME} profile [--raw]"; \
		echo -e "\t profile \tAWS profile to assume"; \
		return 0; \
	}
	aws_sso_required
	${ECHODO} awsls --profiles ${1} --attributes tags,cidr_block aws_*
}
