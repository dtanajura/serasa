$instanceid="i-050c8499bde7754e7"
$securitygroups=$(aws ec2 describe-instances --instance-ids $instanceid --query "Reservations[].Instances[].SecurityGroups[].GroupId[]" --output text --no-verify-ssl --profile contanova)
$novosecuritygroups=" sg-088945ac402b14f87"
$securitygroups=$securitygroups+$novosecuritygroups
aws ec2 modify-instance-attribute --instance-id $instanceid --groups $securitygroups  --no-verify-ssl --profile contanova
