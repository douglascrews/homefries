script_echo "AWS setup..."

alias awscli='aws --cli-auto-prompt'
alias aws_profiles="grep '^\[profile ' ~/.aws/config | sed 's/\[profile \(.*\)\]/\1/'"

function aws_sso_login() {
   ${ECHODO} aws --profile ${1:-service} sso login
}

function aws_sso_account() {
   # help
   [[ "${*}" =~ --help ]] || [[ "${#}" < 0 ]] && {
      echo -e "${funcName}${FUNCNAME} ${pOpt}[profile] ${pOpt}[--quiet]${colorReset}"
      help_param "${pOpt}[profile]" "${helpMsg}AWS profile; default=${pDft}service${colorReset}"
      help_param "${pOpt}[--quiet]" "${helpMsg}No output, return 0 if found or 1 if not found${colorReset}"
      return 0;
   }
   export AWS_ACCOUNT=$(aws sts get-caller-identity --profile ${1:-service} --query "Account" | sed -e 's/"//g' 2>/dev/null);
   if [[ ! "${*}" =~ --quiet ]]; then
      echo ${AWS_ACCOUNT}
   fi
   if [[ -n "${AWS_ACCOUNT}" ]]; then
      return 0;
   else
      return 1;
   fi
}
export -f aws_sso_account

function aws_sso_required() {
   # help
   [[ "${*}" =~ --help ]] || [[ "${#}" < 0 ]] && {
      help_headline "${FUNCNAME}" " [profile] [--quiet]"
      help_param "[profile]" "AWS profile; default=service"
      help_param "[--verbose]" "Output current AWS account id"
      return 0;
   }
   (aws_sso_account ${1:-service} --quiet || aws_sso_login)
   [[ "${*}" =~ --verbose ]] && aws_sso_account
   if [[ -n "${AWS_ACCOUNT}" ]]; then
      return 0;
   else
      return 1;
   fi
}
export -f aws_sso_required

function aws_profile_account() {
   aws --profile ${1:-${AWS_PROFILE:-service}} ec2 describe-security-groups --query 'SecurityGroups[0].OwnerId' --output text
}
export -f aws_profile_account

function aws_assume_role() {
   # help
   [[ "${*}" =~ --help ]] || [[ "${#}" < 1 ]] && {
      help_headline "${FUNCNAME}" " role_arn [profile]"
      help_param "role_arn" "AWS role to assume"
      help_param "[profile] AWS profile to assume (default \"service\")"
      return 0;
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
export -f aws_assume_role

# Execute a command for all known AWS profiles; example: "aws_all aws_rds_list_instances"
function aws_all() {
   for profile in $(aws_profiles); do echodo ${*} ${profile}; done
}

function aws_ecr_get_password() {
   aws --profile ${1:-service} ecr get-login-password
}
export -f aws_ecr_get_password

function aws_cloudtrail_list_events() {
   [[ "${*}" =~ --help ]] || [[ "${#}" < 1 ]] && {
      help_headline ${FUNCNAME} 'profile' '[age_hours]' '[--raw]'
      help_param 'profile' 'AWS profile to assume'
      help_param '[age_hours]' 'Maximum age of CloudTrail events in hours' '24'
      help_param '[--raw]' 'Raw output from AWS CLI'
      return 0;
   }
   aws_sso_required;
   start_datetime=$(date -d "${2:-24} hour ago" --utc "+%Y-%m-%dT%H:%M:%SZ")
   local JQ_QUERY='"\(.eventTime) \(.eventName) \(.eventType) \(.eventCategory) user=\(.userIdentity) params=\(.requestParameters)"'
   [[ "${*}" =~ --raw ]] && JQ_QUERY='.'
   echo "Finding events since ${start_datetime}..."
   aws --profile ${1} cloudtrail lookup-events --start-time ${start_datetime} | jq ".Events[] | .CloudTrailEvent" | sed -e 's/\\\"/\"/g;s/}\"/}/g;s/\"{/{/g;s/\\\\n//g;s/\\\\\"/\"/g' | jq  "${JQ_QUERY}"
}

# Convenience/documentation function for Aurora DSQL PostgreSQL connection
function dsql_connect() {
   # Aurora DSQL requires a valid IAM token as the password when connecting.
   export PGPASSWORD=$(aws dsql generate-db-connect-admin-auth-token --region ${AWS_REGION:-'us-east-1'} --expires-in 3600 --hostname ${PGHOST})

   # Aurora DSQL requires SSL and will reject your connection without it. Defining the env var automagically uses it.
   export PGSSLMODE=require

   psql_connect "${@}"
}
export -f dsql_connect

# Convenience/documentation function for Aurora DSQL PostgreSQL password token generation
function dsql_password() {
   # default params
   local default_host=localhost

   # help
   [[ "${1}" == "--help" ]] || [[ "${1}" == "-h" ]] && {
      help_headline ${FUNCNAME} [hostname]
      help_note "Aurora DSQL requires a valid IAM token as the password when connecting."
      help_param "[hostname]" "Hostname to connect to" "\${PGHOST} or ${default_host}"
      return 0;
   }

   export PGHOST=${1:-${PGHOST:-localhost}}
   export PGPASSWORD=$(aws dsql generate-db-connect-admin-auth-token --region us-east-1 --expires-in 3600 --hostname ${PGHOST})

   # Aurora DSQL requires SSL and will reject your connection without it. Defining the env var automagically uses it.
   export PGSSLMODE=require

   if [[ -n "${PGPASSWORD}" ]]; then
      echo "PGPASSWORD is set."
      return 0
   else
      echo "ERROR setting PGPASSWORD. Did you set \${PGHOST}?"
      return -1
   fi
}
export -f dsql_password

# Convenience/documentation function for Aurora DSQL PostgreSQL script execution
function dsql_run() {
   # Aurora DSQL requires a valid IAM token as the password when connecting.
   export PGPASSWORD=$(aws dsql generate-db-connect-admin-auth-token --region us-east-1 --expires-in 3600 --hostname ${PGHOST:-localhost})

   # Aurora DSQL requires SSL and will reject your connection without it. Defining the env var automagically uses it.
   export PGSSLMODE=require

   psql_run ${@}
}
export -f dsql_run

# Convenience/documentation function for Aurora DSQL PostgreSQL connection test; returns 0 on success, nonzero on failure
function dsql_test() {
   # Aurora DSQL requires a valid IAM token as the password when connecting.
   export PGPASSWORD=$(aws dsql generate-db-connect-admin-auth-token --region us-east-1 --expires-in 3600 --hostname ${PGHOST})

   # Aurora DSQL requires SSL and will reject your connection without it. Defining the env var automagically uses it.
   export PGSSLMODE=require

   psql_test ${@}
}
export -f dsql_test

function aws_dsql_get_cluster() {
   [[ "${*}" =~ --help ]] || [[ "${#}" < 2 ]] && {
      help_headline "${FUNCNAME}" "profile" "[--raw]"
      help_param "profile" "AWS profile to assume"
      help_param "instance_id" "RDS instance ID"
      help_param "[--raw]" "Raw output from AWS CLI"
      return 0;
   }
   aws_sso_required;
   local JQ_QUERY='.'
   [[ "${*}" =~ --raw ]] && JQ_QUERY='.'
   aws dsql get-cluster --profile ${1} --identifier ${2} | jq "${JQ_QUERY}"
}

function aws_dsql_list_clusters() {
   [[ "${*}" =~ --help ]] || [[ "${#}" < 1 ]] && {
      help_headline "${FUNCNAME}" "profile" "[--raw]"
      help_param "profile" "AWS profile to assume"
      help_param "[--raw]" "Raw output from AWS CLI"
      return 0;
   }
   aws_sso_required;
   local JQ_QUERY='.'
   [[ "${*}" =~ --raw ]] && JQ_QUERY='.'
   aws dsql list-clusters --profile ${1} | jq "${JQ_QUERY}"
}

function aws_dsql_get_token() {
   [[ "${*}" =~ --help ]] || [[ "${#}" < 1 ]] && {
      help_headline "${FUNCNAME}" "profile" "hostname" "[--raw]"
      help_param "profile" "AWS profile to assume"
      help_param "hostname" "DSQL cluster hostname for authentication"
      help_param "[--raw]" "Raw output from AWS CLI"
      return 0;
   }
   aws_sso_required;
   local JQ_QUERY='.DBInstances[] | "\(.DBInstanceArn)"'
   [[ "${*}" =~ --raw ]] && JQ_QUERY='.'
   aws dsql generate-db-connect-auth-token --profile ${1} --hostname ${2} | jq "${JQ_QUERY}"
}

function aws_ec2_describe_security_groups() {
   [[ "${*}" =~ --help ]] || [[ "${#}" < 1 ]] && {
      help_headline "${FUNCNAME}" "profile" "[--raw]"
      help_param "profile" "AWS profile to assume"
      help_param "[--raw]" "Raw output from AWS CLI"
      return 0;
   }
   aws_sso_required;
   local JQ_QUERY='.SecurityGroups[] | "\(.GroupId) \(.GroupName) \(.Description)"'
   [[ "${*}" =~ --raw ]] && JQ_QUERY='.'
   aws --profile ${1} ec2 describe-security-groups | sed -e "$\\\"$\"$" | jq "${JQ_QUERY}"
}

function aws_ec2_describe_instances() {
   [[ "${*}" =~ --help ]] || [[ "${#}" < 1 ]] && {
      help_headline "${FUNCNAME}" "profile" "[--raw]"
      help_param "profile" "AWS profile to assume"
      help_param "[--raw]" "Raw output from AWS CLI"
      return 0;
   }
   aws_sso_required;
   local JQ_QUERY='.Reservations[].Instances[] | "\(.InstanceId) \(select(.Tags != null) | .Tags[] | select(.Key == "Name").Value) \(.InstanceType) \(.Placement.AvailabilityZone) \(.State.Name) key:\(.KeyName)"'
   [[ "${*}" =~ --raw ]] && JQ_QUERY='.'
   aws --profile ${1} ec2 describe-instances | jq "${JQ_QUERY}"
}

function aws_ec2_list_instances() {
   [[ "${*}" =~ --help ]] || [[ "${#}" < 1 ]] && {
      help_headline "${FUNCNAME}" "profile" "[--raw]"
      help_param "profile" "AWS profile to assume"
      help_param "[--raw]" "Raw output from AWS CLI"
      return 0;
   }
   aws_sso_required;
   local JQ_QUERY='.Reservations[].Instances[].InstanceId'
   [[ "${*}" =~ --raw ]] && JQ_QUERY='.'
   aws --profile ${1} ec2 describe-instances | jq "${JQ_QUERY}" | sed -e 's/"//g'
}

function aws_ec2_list_security_groups() {
   [[ "${*}" =~ --help ]] || [[ "${#}" < 1 ]] && {
      help_headline "${FUNCNAME}" "profile" "[--raw]"
      help_param "profile" "AWS profile to assume"
      help_param "[--raw]" "Raw output from AWS CLI"
      return 0;
   }
   aws_sso_required;
   local JQ_QUERY='.SecurityGroups[].GroupId'
   [[ "${*}" =~ --raw ]] && JQ_QUERY='.'
   aws --profile ${1} ec2 describe-security-groups | jq "${JQ_QUERY}" | sed -e 's/"//g'
}

function aws_ec2_list_security_group_rules() {
   [[ "${*}" =~ --help ]] || [[ "${#}" < 1 ]] && {
      help_headline "${FUNCNAME}" "profile" "[--raw]"
      help_param "profile" "AWS profile to assume"
      help_param "[--raw]" "Raw output from AWS CLI"
      return 0;
   }
   aws_sso_required;
   local JQ_QUERY='.SecurityGroupRules[] | "\(.GroupId) \(.SecurityGroupRuleId) egress:\(.IsEgress) \(.CidrIpv4):\(.FromPort)~\(.ToPort)"'
   [[ "${*}" =~ --raw ]] && JQ_QUERY='.'
   aws --profile ${1} ec2 describe-security-group-rules | jq "${JQ_QUERY}" | sed -e 's/"//g'
}

function aws_ecr_docker_login() {
   aws_sso_required;
   aws_ecr_get_password | docker login --username AWS --password-stdin ${1:-060724984176.dkr.ecr.us-east-1.amazonaws.com}
}
export -f aws_ecr_docker_login

function aws_eks_list_clusters() {
   [[ "${*}" =~ --help ]] || [[ "${#}" < 1 ]] && {
      help_headline "${FUNCNAME}" "profile" "[--raw]"
      help_param "profile" "AWS profile to assume"
      help_param "[--raw]" "Raw output from AWS CLI"
      return 0;
   }
   aws_sso_required;
   local JQ_QUERY='.clusters[]'
   [[ "${*}" =~ --raw ]] && JQ_QUERY='.'
   aws --profile ${1} eks list-clusters | jq "${JQ_QUERY}" | sed -e 's/"//g'
}

function aws_eks_describe_cluster() {
   [[ "${*}" =~ --help ]] || [[ "${#}" < 1 ]] && {
      help_headline "${FUNCNAME}" "profile" "cluster_name" "[--raw]"
      help_param "profile" "AWS profile to assume"
      help_param "cluster_name" "Cluster name"
      help_param "[--raw]" "Raw output from AWS CLI"
      return 0;
   }
   aws_sso_required;
   local JQ_QUERY='.cluster | "name=\(.name) endpoint=\(.endpoint) cidr=\(.kubernetesNetworkConfig.serviceIpv4Cidr) status=\(.status)"'
   [[ "${*}" =~ --raw ]] && JQ_QUERY='.'
   aws --profile ${1} eks describe-cluster --name ${2:-"ERROR_cluster-name_undefined"} | jq "${JQ_QUERY}"
}

function aws_eks_describe_clusters() {
   [[ "${*}" =~ --help ]] || [[ "${#}" < 1 ]] && {
      help_headline "${FUNCNAME}" " profile"
      help_param "profile" "AWS profile to assume"
      return 0;
   }
   aws_sso_required;
   for kluster in $(aws_eks_list_clusters ${1}); do echodo aws_eks_describe_cluster $kluster; done
}

function aws_elasticache_list_clusters() {
   [[ "${*}" =~ --help ]] || [[ "${#}" < 1 ]] && {
      help_headline "${FUNCNAME}" "profile" "[--raw]"
      help_param "profile" "AWS profile to assume"
      help_param "[--raw]" "Raw output from AWS CLI"
      return 0;
   }
   aws_sso_required;
   local JQ_QUERY='.CacheClusters[] | "id=\(.CacheClusterId) ARN=\(.ARN) engine=\(.Engine) \(.EngineVersion) size=\(.CacheNodeType)"'
   [[ "${*}" =~ --raw ]] && JQ_QUERY='.'
   aws elasticache describe-cache-clusters --profile ${1} | jq -c -C -S -r "${JQ_QUERY}"
}

function aws_elb_list_instances() {
   [[ "${*}" =~ --help ]] || [[ "${#}" < 1 ]] && {
      help_headline "${FUNCNAME}" "profile" "[--raw]"
      help_param "profile" "AWS profile to assume"
      help_param "[--raw]" "Raw output from AWS CLI"
      return 0;
   }
   aws_sso_required;
   local JQ_QUERY='.LoadBalancerDescriptions[].LoadBalancerName'
   [[ "${*}" =~ --raw ]] && JQ_QUERY='.'
   aws --profile ${1} elb describe-load-balancers | jq "${JQ_QUERY}" | sed -e 's/"//g'
}

function aws_iam_describe_role() {
   [[ "${*}" =~ --help ]] || [[ "${#}" < 2 ]] && {
      help_headline "${FUNCNAME}" "profile" "role_name" "[--raw]"
      help_param "profile" "AWS profile to assume"
      help_param "role_name" "Role name"
      help_param "[--raw]" "Raw output from AWS CLI"
      return 0;
   }
   aws_sso_required;
   local JQ_QUERY='.Role'
   [[ "${*}" =~ --raw ]] && JQ_QUERY='.'
   aws --profile ${1} iam get-role --role-name ${2} | jq "${JQ_QUERY}"
}

function aws_iam_describe_role_policy() {
   [[ "${*}" =~ --help ]] || [[ "${#}" < 3 ]] && {
      help_headline "${FUNCNAME}" "profile" "role_name" "[--raw]"
      help_param "profile" "AWS profile to assume"
      help_param "role_name" "Role name"
      help_param "policy_name" "Policy name". \
      help_param "[--raw]" "Raw output from AWS CLI"
      return 0;
   }
   aws_sso_required;
   local JQ_QUERY='.'
   [[ "${*}" =~ --raw ]] && JQ_QUERY='.'
   aws --profile ${1} iam get-role-policy --role-name ${2} --policy-name ${3} | jq "${JQ_QUERY}"
}

function aws_iam_list_role_policies_attached() {
   [[ "${*}" =~ --help ]] || [[ "${#}" < 2 ]] && {
      help_headline "${FUNCNAME}" "profile" "role_name" "[--raw]"
      help_param "profile" "AWS profile to assume"
      help_param "role_name" "Role name to list policies for"
      help_param "[--raw]" "Raw output from AWS CLI"
      return 0;
   }
   aws_sso_required;
   local JQ_QUERY='.AttachedPolicies[].PolicyArn'
   [[ "${*}" =~ --raw ]] && JQ_QUERY='.'
   aws --profile ${1} iam list-attached-role-policies --role-name ${2} | jq "${JQ_QUERY}" | sed -e 's/"//g'
}

function aws_iam_list_roles() {
   [[ "${*}" =~ --help ]] || [[ "${#}" < 1 ]] && {
      help_headline "${FUNCNAME}" "profile" "[--raw]"
      help_param "profile" "AWS profile to assume"
      help_param "[--raw]" "Raw output from AWS CLI"
      return 0;
   }
   aws_sso_required;
   local JQ_QUERY='.Roles[].Arn'
   [[ "${*}" =~ --raw ]] && JQ_QUERY='.'
   aws --profile ${1} iam list-roles | jq "${JQ_QUERY}" | sed -e 's/"//g'
}

function aws_iam_list_role_policies() {
   [[ "${*}" =~ --help ]] || [[ "${#}" < 2 ]] && {
      help_headline "${FUNCNAME}" "profile" "role_name" "[--raw]"
      help_param "profile" "AWS profile to assume"
      help_param "role_name" "Role name to list policies for"
      help_param "[--raw]" "Raw output from AWS CLI"
      return 0;
   }
   aws_sso_required;
   local JQ_QUERY='.PolicyNames[]'
   [[ "${*}" =~ --raw ]] && JQ_QUERY='.'
   aws --profile ${1} iam list-role-policies --role-name ${2} | jq "${JQ_QUERY}" | sed -e 's/"//g'
}

function aws_iam_list_user_policies() {
   [[ "${*}" =~ --help ]] || [[ "${#}" < 2 ]] && {
      help_headline "${FUNCNAME}" "profile" "user_name" "[--raw]"
      help_param "profile" "AWS profile to assume"
      help_param "user_name" "User name to list policies for"
      help_param "[--raw]" "Raw output from AWS CLI"
      return 0;
   }
   aws_sso_required;
   local JQ_QUERY='.AttachedPolicies[].PolicyArn'
   [[ "${*}" =~ --raw ]] && JQ_QUERY='.'
   aws --profile ${1} iam list-attached-user-policies --user-name ${2} | jq "${JQ_QUERY}" | sed -e 's/"//g'
}

function aws_kms_describe_key() {
   [[ "${*}" =~ --help ]] || [[ "${#}" < 2 ]] && {
      help_headline "${FUNCNAME}" "profile" "key-id" "[--raw]"
      help_param "profile" "AWS profile to assume"
      help_param "key_id" "KMS key id to describe"
      help_param "[--raw]" "Raw output from AWS CLI"
      return 0;
   }
   aws_sso_required;
   local JQ_QUERY='.Keys[].KeyArn'
   [[ "${*}" =~ --raw ]] && JQ_QUERY='.'
   aws --profile ${1} kms describe-key --key-id ${2} | jq "${JQ_QUERY}" 
}

function aws_kms_list_keys() {
   [[ "${*}" =~ --help ]] || [[ "${#}" < 1 ]] && {
      help_headline "${FUNCNAME}" "profile" "[--raw]"
      help_param "profile" "AWS profile to assume"
      help_param "[--raw]" "Raw output from AWS CLI"
      return 0;
   }
   aws_sso_required;
   local JQ_QUERY='.Keys[].KeyArn'
   [[ "${*}" =~ --raw ]] && JQ_QUERY='.'
   aws --profile ${1} kms list-keys | jq "${JQ_QUERY}" | sed -e 's/"//g'   
}

function aws_lambda_describe_functions() {
   [[ "${*}" =~ --help ]] || [[ "${#}" < 1 ]] && {
      help_headline "${FUNCNAME}" "profile" "[--raw]"
      help_param "profile" "AWS profile to assume"
      help_param "[--raw]" "Raw output from AWS CLI"
      return 0;
   }
   aws_sso_required;
   local JQ_QUERY='.Functions[] | "\(.FunctionName) \(.Runtime) \(.Handler) \(.Version) CodeSize: \(.CodeSize) Role: \(.Role) \(.Description)"'
   [[ "${*}" =~ --raw ]] && JQ_QUERY='.'
   aws --profile ${1} lambda list-functions | jq "${JQ_QUERY}"
}

function aws_lambda_list_functions() {
   [[ "${*}" =~ --help ]] || [[ "${#}" < 1 ]] && {
      help_headline "${FUNCNAME}" "profile" "[--raw]"
      help_param "profile" "AWS profile to assume"
      help_param "[--raw]" "Raw output from AWS CLI"
      return 0;
   }
   aws_sso_required;
   local JQ_QUERY='.Functions[].FunctionArn'
   [[ "${*}" =~ --raw ]] && JQ_QUERY='.'
   aws --profile ${1} lambda list-functions | jq "${JQ_QUERY}" | sed -e 's/"//g'
}

function aws_lambda_invoke_function() {
   [[ "${*}" =~ --help ]] || [[ "${#}" < 2 ]] && {
      help_headline "${FUNCNAME}" "profile" "func_name [payload]"
      help_param "profile" "AWS profile to assume"
      help_param "func_name" "Function name to invoke"
      help_param "[payload]" "Function payload in JSON format"
      return 0;
   }
   aws_sso_required;
   local OUTPUT=$(aws --profile ${1} lambda invoke --function-name ${2} --log-type Tail -)
   echo ${OUTPUT} | jq ".StatusCode"
   echo ${OUTPUT} | jq ".LogResult" | sed -e 's/"//g' | base64 --decode
}

function aws_rds_describe_instance() {
   [[ "${*}" =~ --help ]] || [[ "${#}" < 2 ]] && {
      help_headline "${FUNCNAME}" "profile" "[--raw]"
      help_param "profile" "AWS profile to assume"
      help_param "instance_id" "RDS instance ID"
      help_param "[--raw]" "Raw output from AWS CLI"
      return 0;
   }
   aws_sso_required;
   local JQ_QUERY='.DBInstances[] | "\(.DBInstanceArn) \(.DBInstanceClass) \(.Engine)\(.EngineVersion) \(.Endpoint.Address):\(.Endpoint.Port)"'
   [[ "${*}" =~ --raw ]] && JQ_QUERY='.'
   aws rds describe-db-instances --profile ${1} --db-instance-identifier ${2} | jq "${JQ_QUERY}"
}

function aws_rds_describe_instances() {
   [[ "${*}" =~ --help ]] || [[ "${#}" < 1 ]] && {
      help_headline "${FUNCNAME}" "profile" "[--raw]"
      help_param "profile" "AWS profile to assume"
      help_param "[--raw]" "Raw output from AWS CLI"
      return 0;
   }
   aws_sso_required;
   local JQ_QUERY='.DBInstances[] | "\(.DBInstanceArn) \(.DBInstanceClass) \(.Engine)\(.EngineVersion) \(.Endpoint.Address):\(.Endpoint.Port)"'
   [[ "${*}" =~ --raw ]] && JQ_QUERY='.'
   aws rds describe-db-instances --profile ${1} | jq "${JQ_QUERY}"
}

function aws_rds_list_instances() {
   [[ "${*}" =~ --help ]] || [[ "${#}" < 1 ]] && {
      help_headline "${FUNCNAME}" "profile" "[--raw]"
      help_param "profile" "AWS profile to assume"
      help_param "[--raw]" "Raw output from AWS CLI"
      return 0;
   }
   aws_sso_required;
   local JQ_QUERY='.DBInstances[] | "\(.DBInstanceArn)"'
   [[ "${*}" =~ --raw ]] && JQ_QUERY='.'
   aws rds describe-db-instances --profile ${1} | jq "${JQ_QUERY}" | sed -e 's/"//g'
}

function aws_rds_describe_snapshots() {
   [[ "${*}" =~ --help ]] || [[ "${#}" < 1 ]] && {
      help_headline "${FUNCNAME}" "profile" "[snapshot_type]" "[--raw]"
      help_param "profile" "AWS profile to assume"
      help_param "[snapshot_type]" "Snapshot type: automated,manual,shared,public,awsbackup; default ALL"
      help_param "[--raw]" "Raw output from AWS CLI"
      return 0;
   }
   aws_sso_required;
   [[ "${2}" == "automated" ]] || [[ "${2}" == "manual" ]] || [[ "${2}" == "shared" ]] || [[ "${2}" == "public" ]] || [[ "${2}" == "awsbackup" ]] && local SNAPSHOT_TYPE_PARAM=--snapshot-type && local SNAPSHOT_TYPE_VALUE=${2}
   local JQ_QUERY='.DBSnapshots[] | "\(.DBSnapshotIdentifier) \(.Engine) \(.EngineVersion) \(.Status) \(.SnapshotType) \(.AvailabilityZone) \(.SnapshotCreateTime)"'
   [[ "${*}" =~ --raw ]] && JQ_QUERY='.'
   aws rds describe-db-snapshots --profile ${1} ${SNAPSHOT_TYPE_PARAM} ${SNAPSHOT_TYPE_VALUE} | jq "${JQ_QUERY}"
}

function aws_rds_list_snapshots() {
   [[ "${*}" =~ --help ]] || [[ "${#}" < 1 ]] && {
      help_headline "${FUNCNAME}" "profile" "[snapshot_type]" "[--raw]"
      help_param "profile" "AWS profile to assume"
      help_param "[snapshot_type]" "Snapshot type: automated,manual,shared,public,awsbackup; default ALL"
      help_param "[--raw]" "Raw output from AWS CLI"
      return 0;
   }
   aws_sso_required;
   [[ "${2}" == "automated" ]] || [[ "${2}" == "manual" ]] || [[ "${2}" == "shared" ]] || [[ "${2}" == "public" ]] || [[ "${2}" == "awsbackup" ]] && local SNAPSHOT_TYPE_PARAM=--snapshot-type && local SNAPSHOT_TYPE_VALUE=${2}
   local JQ_QUERY='.DBSnapshots[] | "\(.DBSnapshotArn) \(.SnapshotType)"'
   [[ "${*}" =~ --raw ]] && JQ_QUERY='.'
   aws rds describe-db-snapshots --profile ${1} ${SNAPSHOT_TYPE_PARAM} ${SNAPSHOT_TYPE_VALUE} | jq "${JQ_QUERY}" | sed -e 's/"//g'
}

function aws_route53_list_hosted_zones() {
   [[ "${*}" =~ --help ]] || [[ "${#}" < 1 ]] && {
      help_headline "${FUNCNAME}" "profile" "[--raw]"
      help_param "profile" "AWS profile to assume"
      help_param "[--raw]" "Raw output from AWS CLI"
      return 0;
   }
   aws_sso_required;
   local JQ_QUERY='.HostedZones[].Name'
   [[ "${*}" =~ --raw ]] && JQ_QUERY='.'
   aws --profile ${1} route53 list-hosted-zones | jq "${JQ_QUERY}" | sed -e 's/"//g'
}

function aws_secrets_get_secret() {
   [[ "${*}" =~ --help ]] || [[ "${#}" < 2 ]] && {
      help_headline "${FUNCNAME}" "profile" "secret_id" "[--raw]"
      help_param "profile" "AWS profile to assume"
      help_param "secret_id" "Secret ID"
      help_param "[--raw]" "Raw output from AWS CLI"
      return 0;
   }
   aws_sso_required;
   local JQ_QUERY='.SecretString'
   [[ "${*}" =~ --raw ]] && JQ_QUERY='.'
   aws --profile ${1} secretsmanager get-secret-value --secret-id ${2} | jq "${JQ_QUERY}" | sed -e 's/"//g'
}
export -f aws_secrets_get_secret

function aws_secrets_list_secrets() {
   [[ "${*}" =~ --help ]] || [[ "${#}" < 1 ]] && {
      help_headline "${FUNCNAME}" "profile" "[--raw]"
      help_param "profile" "AWS profile to assume"
      help_param "[--raw]" "Raw output from AWS CLI"
      return 0;
   }
   aws_sso_required;
   local JQ_QUERY='.SecretList[] | "\(.Name) \(.Description) \(.ARN)"'
   [[ "${*}" =~ --raw ]] && JQ_QUERY='.'
   aws --profile ${1} secretsmanager list-secrets | jq "${JQ_QUERY}" | sed -e 's/"//g'
}

function aws_transfer_describe_server() {
   [[ "${*}" =~ --help ]] || [[ "${#}" < 2 ]] && {
      help_headline "${FUNCNAME}" "profile" "server_id" "[--raw]"
      help_param "profile" "AWS profile to assume"
      help_param "server_id" "AWS Transfer Family server ID"
      help_param "[--raw]" "Raw output from AWS CLI"
      return 0;
   }
   aws_sso_required;
   local JQ_QUERY='.Server | "\(.Arn) \(.State) \(.Domain) \(.EndpointType) \(.Protocols[])"'
   [[ "${*}" =~ --raw ]] && JQ_QUERY='.'
   aws --profile ${1} transfer describe-server --server-id ${2} | jq "${JQ_QUERY}"
}

function aws_transfer_list_endpoints() {
   [[ "${*}" =~ --help ]] || [[ "${#}" < 1 ]] && {
      help_headline "${FUNCNAME}" "profile" "[--with-users]"
      help_param "profile" "AWS profile to assume"
      help_param "[--with-users]" "List users for each server"
      return 0;
   }
   aws_sso_required;
   for f in $(aws --profile ${1} transfer list-servers | jq '.Servers[] | .Arn' | sed 's/"//g') ; do
      # arn:aws:transfer:us-east-1:232720106935:server/s-feee11aa804c44cd8 -> s-feee11aa804c44cd8.server.transfer.us-east-1.amazonaws.com
      server_id=$(echo ${f} | cut -d':' -f 6 | cut -d'/' -f 2);
      aws_region=$(echo ${f} | cut -d':' -f 4);
      endpoint=${server_id}.server.transfer.${aws_region}.amazonaws.com;
      echo ${endpoint};
      if [[ "${*}" =~ --with-users ]]; then
         for u in $(aws --profile ${1} transfer list-users --server-id ${server_id} | jq '.Users[] | .UserName' | sed 's/"//g') ; do
            echo -e "\t${u}";
         done;
      fi;
   done;
}

function aws_transfer_list_servers() {
   [[ "${*}" =~ --help ]] || [[ "${#}" < 1 ]] && {
      help_headline "${FUNCNAME}" "profile" "[--raw]"
      help_param "profile" "AWS profile to assume"
      help_param "[--raw]" "Raw output from AWS CLI"
      return 0;
   }
   aws_sso_required;
   local JQ_QUERY='.Servers[] | "\(.Arn) \(.State) \(.Domain) \(.EndpointType) \(.EntityProviderType)"'
   [[ "${*}" =~ --raw ]] && JQ_QUERY='.'
   aws --profile ${1} transfer list-servers | jq "${JQ_QUERY}" | sed -e 's/"//g'
}

function aws_transfer_list_users() {
   [[ "${*}" =~ --help ]] || [[ "${#}" < 2 ]] && {
      help_headline "${FUNCNAME}" "profile" "server_id" "[--raw]"
      help_param "profile" "AWS profile to assume"
      help_param "server_id" "AWS Transfer Family server ID"
      help_param "[--raw]" "Raw output from AWS CLI"
      return 0;
   }
   aws_sso_required;
   local JQ_QUERY='.Users[] | "\(.Arn) \(.Role) \(.HomeDirectoryType) keys=\(.SshPublicKeyCount)"'
   [[ "${*}" =~ --raw ]] && JQ_QUERY='.'
   aws --profile ${1} transfer list-users --server-id ${2} | jq "${JQ_QUERY}" | sed -e 's/"//g'
}

function aws_vpc_list() {
#  awsls --profiles ${1:-dougcrews} --attributes tags,cidr_block aws_vpc
   [[ "${*}" =~ --help ]] || [[ "${#}" < 1 ]] && {
      help_headline "${FUNCNAME}" "profile" "[--raw]"
      help_param "profile" "AWS profile to assume"
      help_param "[--raw]" "Raw output from AWS CLI"
      return 0;
   }
   aws_sso_required;
   local JQ_QUERY='.Vpcs[] | "id=\(.VpcId) cidr=\(.CidrBlock) owner=\(.OwnerId) default=\(.IsDefault)"'
   [[ "${*}" =~ --raw ]] && JQ_QUERY='.'
   aws ec2 describe-vpcs --profile ${1} | jq -r "${JQ_QUERY}"
}

function aws_all_list() {
   [[ "${*}" =~ --help ]] || [[ "${#}" < 1 ]] && {
      help_headline "${FUNCNAME}" "[profile]"
      help_param "[profile]" "AWS profile to assume"
      return 0;
   }
   aws_sso_required;
   ${ECHODO} awsls --profiles ${1} --attributes tags,cidr_block aws_*
}

aws --version
