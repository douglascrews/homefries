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

# Execute a command for all known AWS profiles; example: "aws_all aws_rds_list_instances"
aws_all() {
	for profile in $(aws_profiles); do echodo ${*} ${profile}; done
}

aws_ecr_get_password() {
   aws --profile ${1:-service} ecr get-login-password
}

aws_eks_list_clusters() {
	[[ "${args[@]}" == "--help" ]] || [[ "${args[@]}" == "-h" ]] && { \
		echo -e "${FUNCNAME}(aws_profile)"; \
		echo -e "\n\t aws_profile AWS profile name"; \
		return 0; \
	}
	aws_sso_required
	aws --profile ${1} eks list-clusters | jq ".clusters[]"
}
aws_eks_describe_cluster() {
	[[ "${args[@]}" == "--help" ]] || [[ "${args[@]}" == "-h" ]] || [[ -z ${2} ]] && { \
		echo -e "${FUNCNAME}(aws_profile, cluster_name)"; \
		echo -e "\n\t aws_profile AWS profile name"; \
		echo -e "\n\t cluster_name Cluster name"; \
		return 0; \
	}
	aws_sso_required
	aws --profile ${1} eks describe-cluster --name ${2:-"ERROR_cluster-name_undefined"} | jq '.cluster | "name=\(.name) endpoint=\(.endpoint) cidr=\(.kubernetesNetworkConfig.serviceIpv4Cidr) status=\(.status)"'
}
aws_eks_describe_clusters() {
	[[ "${args[@]}" == "--help" ]] || [[ "${args[@]}" == "-h" ]] && { \
		echo -e "${FUNCNAME}(aws_profile)"; \
		echo -e "\n\t aws_profile AWS profile name"; \
		return 0; \
	}
	aws_sso_required
	for kluster in $(aws_eks_list_clusters ${1}); do echodo aws_eks_describe_cluster $kluster; done
}

aws_elasticache_list_clusters() {
	[[ "${args[@]}" == "--help" ]] || [[ "${args[@]}" == "-h" ]] && { \
		echo -e "${FUNCNAME}(aws_profile)"; \
		echo -e "\n\t aws_profile AWS profile name"; \
		return 0; \
	}
	aws_sso_required
   aws elasticache describe-cache-clusters --profile ${1} | jq -c -C -S -r '.CacheClusters[] | "
id=\(.CacheClusterId) ARN=\(.ARN) engine=\(.Engine) \(.EngineVersion) size=\(.CacheNodeType)"'
}

aws_elb_list_instances() {
	[[ "${args[@]}" == "--help" ]] || [[ "${args[@]}" == "-h" ]] && { \
		echo -e "${FUNCNAME}(aws_profile)"; \
		echo -e "\n\t aws_profile AWS profile name"; \
		return 0; \
	}
	aws_sso_required
	aws --profile ${1} elb describe-load-balancers | jq ".LoadBalancerDescriptions[].LoadBalancerName"
}

aws_lambda_list_functions() {
	[[ "${args[@]}" == "--help" ]] || [[ "${args[@]}" == "-h" ]] && { \
		echo -e "${FUNCNAME}(aws_profile)"; \
		echo -e "\n\t aws_profile AWS profile name"; \
		return 0; \
	}
	aws_sso_required
	aws --profile ${1} lambda list-functions | jq '.Functions[] | "\(.FunctionName) \(.Runtime) \(.Handler) \(.Version) \(.FunctionArn) \(.Role)"'
}

aws_lambda_invoke_function() {
	[[ "${args[@]}" == "--help" ]] || [[ "${args[@]}" == "-h" ]] || [[ -z "${2}" ]] && { \
		echo -e "${FUNCNAME}(aws_profile, func_name)"; \
		echo -e "\n\t aws_profile AWS profile name"; \
		echo -e "\n\t func_name Function name to invoke"; \
		return 0; \
	}
	aws_sso_required
	local OUTPUT=$(aws --profile ${1} lambda invoke --function-name ${2} --log-type Tail -)
	echo ${OUTPUT} | jq ".StatusCode"
	echo ${OUTPUT} | jq ".LogResult" | sed -e 's/"//g' | base64 --decode
}


aws_rds_list_instances() {
	([[ "${args[@]}" == "--help" ]] || [[ "${args[@]}" == "-h" ]]) && { \
		echo -e "${FUNCNAME}(aws_profile)"; \
		echo -e "\n\t aws_profile AWS profile name"; \
		return 0; \
	}
	aws_sso_required
	aws rds describe-db-instances --profile ${1} | jq '.DBInstances[] | "\(.DBInstanceIdentifier) \(.DBInstanceClass) \(.Engine)\(.EngineVersion) \(.DBInstanceStatus) \(.Endpoint.Address):\(.Endpoint.Port)"'
}

aws_rds_list_instances_details() {
	[[ "${args[@]}" == "--help" ]] || [[ "${args[@]}" == "-h" ]] && { \
		echo -e "${FUNCNAME}(aws_profile)"; \
		echo -e "\n\t aws_profile AWS profile name"; \
		return 0; \
	}
	aws_sso_required
	aws rds describe-db-instances --profile ${1} | jq '.DBInstances[] | "\(.DBInstanceIdentifier) \(.DBInstanceClass) \(.Engine) \(.EngineVersion) \(.Endpoint.Address):\(.Endpoint.Port) \(.AvailabilityZone) \(.AllocatedStorage)GB"'
}

aws_rds_describe_snapshots() {
	[[ "${args[@]}" == "--help" ]] || [[ "${args[@]}" == "-h" ]] && { \
		echo -e "${FUNCNAME}(aws_profile)"; \
		echo -e "\n\t aws_profile AWS profile name"; \
		return 0; \
	}
	aws_sso_required
	aws rds describe-db-snapshots --profile ${1} | jq '.DBSnapshots[] | "\(.DBSnapshotIdentifier) \(.Engine) \(.EngineVersion) \(.Status) \(.SnapshotType) \(.SnapshotCreateTime)"'
}

aws_rds_list_snapshots() {
	[[ "${args[@]}" == "--help" ]] || [[ "${args[@]}" == "-h" ]] && { \
		echo -e "${FUNCNAME}(aws_profile)"; \
		echo -e "\n\t aws_profile AWS profile name"; \
		return 0; \
	}
	aws_sso_required
	aws rds describe-db-snapshots --profile ${1} | jq ".DBSnapshots[].DBSnapshotIdentifier"
}

aws_route53_list_hosted_zones() {
	[[ "${args[@]}" == "--help" ]] || [[ "${args[@]}" == "-h" ]] && { \
		echo -e "${FUNCNAME}(aws_profile)"; \
		echo -e "\n\t aws_profile AWS profile name"; \
		return 0; \
	}
	aws_sso_required
	aws --profile ${1} route53 list-hosted-zones | jq ".HostedZones[].Name"
}

aws_vpc_list() {
#	awsls --profiles ${1:-dougcrews} --attributes tags,cidr_block aws_vpc
	[[ "${args[@]}" == "--help" ]] || [[ "${args[@]}" == "-h" ]] && { \
		echo -e "${FUNCNAME}(aws_profile)"; \
		echo -e "\n\t aws_profile AWS profile name"; \
		return 0; \
	}
	aws_sso_required
	aws ec2 describe-vpcs --profile ${1} | jq -r '.Vpcs[] | "id=\(.VpcId) cidr=\(.CidrBlock) owner=\(.OwnerId) default=\(.IsDefault)"'
}

aws_all_list() {
	[[ "${args[@]}" == "--help" ]] || [[ "${args[@]}" == "-h" ]] && { \
		echo -e "${FUNCNAME}(aws_profile)"; \
		echo -e "\n\t aws_profile AWS profile name"; \
		return 0; \
	}
	aws_sso_required
	${ECHODO} awsls --profiles ${1} --attributes tags,cidr_block aws_*
}
