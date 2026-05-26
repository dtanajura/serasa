aws ec2 describe-instances --query 'Reservations[].Instances[].{Name:Tags[?Key==`Name`]|[0].Value,Resource:Tags[?Key==`ResourceName`]|[0].Value,Instance:InstanceId,State:State.Name,IP:PrivateIpAddress,AMI:ImageId,AZ:Placement.AvailabilityZone,Tipo:InstanceType,Chave:KeyName,VPC:VpcId,Subnet:SubnetId}' --output table
aws ec2 describe-subnets
C:\Users\c96531a>aws --version
aws-cli/2.0.9 Python/3.7.5 Windows/10 botocore/2.0.0dev13

#Levantamento das EC2s
aws ec2 describe-instances --query "Reservations[].Instances[].{ID:InstanceId,Tipo:InstanceType,VPC:VpcId,Subnet:SubnetId,State:State.Name,IP:PrivateIpAddress,AMI:ImageId,AZ:Placement.AvailabilityZone,Name:Tags[?Key=='Name'].Value}" --output table --profile devhub-sandbox --no-verify-ssl
aws ec2 describe-instances --query "Reservations[].Instances[].{ID:InstanceId,Tipo:InstanceType,VPC:VpcId,Subnet:SubnetId,State:State.Name,IP:PrivateIpAddress,AMI:ImageId,AZ:AvailabilityZone,Name:Tags.[?Key=='Name']}" --output table --profile devhub-sandbox --no-verify-ssl
