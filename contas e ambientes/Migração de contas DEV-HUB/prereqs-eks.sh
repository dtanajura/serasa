# Verificação dos tags das VPCs das contas
### conta Lab 01
## Validate if your VPC:
## a) is tagged with "AWS_Solutions = LandingZoneStackSet"
aws ec2 describe-vpcs --profile lab01 --no-verify-ssl --query "Vpcs[*].{Name:Tags[?Key=='Name']|[*].Value,AWS_Solutions:Tags[?Key=='AWS_Solutions']|[*].Value}" --output table
----------------------------
|       DescribeVpcs       |
||      AWS_Solutions     ||
|+------------------------+|
||  LandingZoneStackSet   ||
|+------------------------+|
||          Name          ||
|+------------------------+|
||  aws-landing-zone-VPC  ||
|+------------------------+|
## your Experian IP range subnets with "Network = Private" and the Pod IP range (100.64.0.0/16) subnets with "Network = Pod".
aws ec2 describe-subnets --profile lab01 --no-verify-ssl  --query "Subnets[].{Name:Tags[?Key=='Name']|[].Value,Network:Tags[?Key=='Network']|[].Value,CidrBlock:CidrBlock}" --output table
ok
## Firewall Rules

Your AWS CIDR/Subnet 
10.99.241.0/27
10.99.241.32/27
10.99.241.64/27

10.99.241.192/27
10.99.241.128/27
10.99.241.160/27

10.99.242.32/27
10.99.242.64/27
10.99.242.0/27

10.99.242.192/27
10.99.242.128/27
10.99.242.160/27

10.99.11.160/27
10.99.11.192/27
10.99.11.128/27

Destination
10.52.149.0/24	TCP	443	

Business Justification
Due to the migration from AppCanvas to EKS we need the VPC to have access in our Nexus Repository to download some Helm charts for VPC CNI and Observability.

The traffic will go through the CSS Egress (CSS firewall rule must be applied).

