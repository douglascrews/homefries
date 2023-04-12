script_echo AWS setup...

alias awscli='aws --cli-auto-prompt'
alias aws_vpc_list='awsls --profiles dougcrews --attributes tags,cidr_block aws_vpc'
alias aws_all_list='awsls --profiles dougcrews --attributes tags,cidr_block aws_*'
