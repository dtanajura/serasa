# Assume role e comunicação entre contas para uso do MSK
## 1ª task conta datahub-dev com MSK na conta dataservices-dev
### Verificar se existe comunicação de firewall entre contas
#### Listar clusters MSK na conta dataservices-dev
okta-aws-cli web --profile datahubdev --aws-region sa-east-1 --aws-session-duration 36000
okta-aws-cli web --profile dataservicesdev --aws-region sa-east-1 --aws-session-duration 36000

aws kafka list-clusters --profile dataservicesdev
{
    "ClusterInfoList": [
        {
            "BrokerNodeGroupInfo": {
                "BrokerAZDistribution": "DEFAULT",
                "ClientSubnets": [
                    "subnet-007a05702ba40bcf9",
                    "subnet-089c306d82d27f955"
                ],
                "InstanceType": "kafka.t3.small",
                "SecurityGroups": [
                    "sg-010712e8063ae38ef",
                    "sg-0b019fa6136fd5555"
                ],
                "StorageInfo": {
                    "EbsStorageInfo": {
                        "ProvisionedThroughput": {
                            "Enabled": false
                        },
                        "VolumeSize": 1000
                    }
                },
                "ConnectivityInfo": {
                    "PublicAccess": {
                        "Type": "DISABLED"
                    },
                    "VpcConnectivity": {
                        "ClientAuthentication": {
                            "Sasl": {
                                "Scram": {
                                    "Enabled": false
                                },
                                "Iam": {
                                    "Enabled": false
                                }
                            },
                            "Tls": {
                                "Enabled": false
                            }
                        }
                    }
                },
                "ZoneIds": [
                    "sae1-az1",
                    "sae1-az2"
                ]
            },
            "ClientAuthentication": {
                "Sasl": {
                    "Scram": {
                        "Enabled": true
                    },
                    "Iam": {
                        "Enabled": true
                    }
                },
                "Tls": {
                    "CertificateAuthorityArnList": [],
                    "Enabled": false
                },
                "Unauthenticated": {
                    "Enabled": true
                }
            },
            "ClusterArn": "arn:aws:kafka:sa-east-1:530914589075:cluster/ds-msk-dev/5918cb83-9fef-47b8-afcb-6f15d88e0d06-3",
            "ClusterName": "ds-msk-dev",
            "CreationTime": "2022-09-21T18:54:16.435000+00:00",
            "CurrentBrokerSoftwareInfo": {
                "ConfigurationArn": "arn:aws:kafka:sa-east-1:530914589075:configuration/ds-msk-config-dev/5d276218-6ccb-44ed-8b31-567708ed2fac-3",
                "ConfigurationRevision": 2,
                "KafkaVersion": "2.8.1"
            },
            "CurrentVersion": "K1YNQOO2NMG7Q7",
            "EncryptionInfo": {
                "EncryptionAtRest": {
                    "DataVolumeKMSKeyId": "arn:aws:kms:sa-east-1:530914589075:key/c666addb-846a-41f6-8b17-b0d116a22681"
                },
                "EncryptionInTransit": {
                    "ClientBroker": "TLS",
                    "InCluster": true
                }
            },
            "EnhancedMonitoring": "DEFAULT",
            "OpenMonitoring": {
                "Prometheus": {
                    "JmxExporter": {
                        "EnabledInBroker": false
                    },
                    "NodeExporter": {
                        "EnabledInBroker": false
                    }
                }
            },
            "LoggingInfo": {
                "BrokerLogs": {
                    "CloudWatchLogs": {
                        "Enabled": true,
                        "LogGroup": "ds-msk-dev"
                    },
                    "Firehose": {
                        "Enabled": false
                    },
                    "S3": {
                        "Enabled": false
                    }
                }
            },
            "NumberOfBrokerNodes": 4,
            "State": "ACTIVE",
            "Tags": {
                "map-migrated": "d-server-02n52mmgua5hr6",
                "project": "nike",
                "Name": "ds-msk-dev"
            },
            "ZookeeperConnectString": "z-2.dsmskdev.w4793t.c3.kafka.sa-east-1.amazonaws.com:2181,z-1.dsmskdev.w4793t.c3.kafka.sa-east-1.amazonaws.com:2181,z-3.dsmskdev.w4793t.c3.kafka.sa-east-1.amazonaws.com:2181",
            "ZookeeperConnectStringTls": "z-2.dsmskdev.w4793t.c3.kafka.sa-east-1.amazonaws.com:2182,z-1.dsmskdev.w4793t.c3.kafka.sa-east-1.amazonaws.com:2182,z-3.dsmskdev.w4793t.c3.kafka.sa-east-1.amazonaws.com:2182",
            "StorageMode": "LOCAL",
            "CustomerActionStatus": "NONE"
        }
    ]
}

#### testar comunicação de um servidor na conta Datahub com o cluster MSK
aws kafka get-bootstrap-brokers \
  --cluster-arn arn:aws:kafka:sa-east-1:530914589075:cluster/ds-msk-dev/5918cb83-9fef-47b8-afcb-6f15d88e0d06-3 \
  --profile dataservicesdev
{
    "BootstrapBrokerStringTls": "b-3.dsmskdev.w4793t.c3.kafka.sa-east-1.amazonaws.com:9094,b-4.dsmskdev.w4793t.c3.kafka.sa-east-1.amazonaws.com:9094,b-2.dsmskdev.w4793t.c3.kafka.sa-east-1.amazonaws.com:9094",
    "BootstrapBrokerStringSaslScram": "b-3.dsmskdev.w4793t.c3.kafka.sa-east-1.amazonaws.com:9096,b-4.dsmskdev.w4793t.c3.kafka.sa-east-1.amazonaws.com:9096,b-2.dsmskdev.w4793t.c3.kafka.sa-east-1.amazonaws.com:9096",
    "BootstrapBrokerStringSaslIam": "b-3.dsmskdev.w4793t.c3.kafka.sa-east-1.amazonaws.com:9098,b-4.dsmskdev.w4793t.c3.kafka.sa-east-1.amazonaws.com:9098,b-2.dsmskdev.w4793t.c3.kafka.sa-east-1.amazonaws.com:9098"
}

$ BROKER=b-3.dsmskdev.w4793t.c3.kafka.sa-east-1.amazonaws.com
$ nslookup $BROKER
Server:         10.121.13.2
Address:        10.121.13.2#53

Non-authoritative answer:
Name:   b-3.dsmskdev.w4793t.c3.kafka.sa-east-1.amazonaws.com
Address: 10.99.8.92

$ $nc -zv $BROKER 9094
Ncat: Version 7.93 ( https://nmap.org/ncat )
Ncat: TIMEOUT.
$ $nc -zv $BROKER 9096
Ncat: Version 7.93 ( https://nmap.org/ncat )
Ncat: TIMEOUT.
$ nc -zv $BROKER 9098
Ncat: Version 7.93 ( https://nmap.org/ncat )
Ncat: TIMEOUT.

##### Verificar security groups do cluster MSK
aws kafka describe-cluster \
  --cluster-arn arn:aws:kafka:sa-east-1:530914589075:cluster/ds-msk-dev/5918cb83-9fef-47b8-afcb-6f15d88e0d06-3 \
  --profile dataservicesdev \
  --query "ClusterInfo.BrokerNodeGroupInfo.SecurityGroups"
[
    "sg-010712e8063ae38ef",
    "sg-0b019fa6136fd5555"
]
c96531a@MACFM7P993G ~ % aws ec2 describe-security-groups \
  --group-ids sg-010712e8063ae38ef \
  --profile dataservicesdev
{
    "SecurityGroups": [
        {
            "Description": "default VPC security group",
            "GroupName": "default",
            "IpPermissions": [],
            "OwnerId": "530914589075",
            "GroupId": "sg-010712e8063ae38ef",
            "IpPermissionsEgress": [],
            "Tags": [
                {
                    "Key": "Name",
                    "Value": "Postgre"
                }
            ],
            "VpcId": "vpc-027d5d299dc8bbb04"
        }
    ]
}
c96531a@MACFM7P993G ~ % aws ec2 describe-security-groups \
  --group-ids sg-0b019fa6136fd5555 \ 
  --profile dataservicesdev
{
    "SecurityGroups": [
        {
            "Description": "ds-msk-dev-sg",
            "GroupName": "ds-msk-dev-sg",
            "IpPermissions": [
                {
                    "FromPort": 9098,
                    "IpProtocol": "tcp",
                    "IpRanges": [
                        {
                            "CidrIp": "10.0.0.0/16",
                            "Description": "serasa internal"
                        },
                        {
                            "CidrIp": "10.99.8.64/26",
                            "Description": "internal aws"
                        },
                        {
                            "CidrIp": "10.0.0.0/8"
                        }
                    ],
                    "Ipv6Ranges": [],
                    "PrefixListIds": [],
                    "ToPort": 9098,
                    "UserIdGroupPairs": []
                },
...

                {
                    "FromPort": 9094,
                    "IpProtocol": "tcp",
                    "IpRanges": [
                        {
                            "CidrIp": "10.96.0.0/15",
                            "Description": "vpn serasa"
                        },
                        {
                            "CidrIp": "10.99.8.64/26",
                            "Description": "internal aws"
                        },
                        {
                            "CidrIp": "10.99.85.0/24",
                            "Description": "internal subnet"
                        },
                        {
                            "CidrIp": "100.64.0.0/16",
                            "Description": "internal k8s"
                        }
                    ],
                    "Ipv6Ranges": [],
                    "PrefixListIds": [],
                    "ToPort": 9094,
                    "UserIdGroupPairs": []
                },
...
                {
                    "FromPort": 9096,
                    "IpProtocol": "tcp",
                    "IpRanges": [
                        {
                            "CidrIp": "10.0.0.0/8",
                            "Description": "liberar porta msk"
                        }
                    ],
                    "Ipv6Ranges": [],
                    "PrefixListIds": [],
                    "ToPort": 9096,
                    "UserIdGroupPairs": []
                },
...
                {
                    "FromPort": 9092,
                    "IpProtocol": "tcp",
                    "IpRanges": [
                        {
                            "CidrIp": "10.96.0.0/15",
                            "Description": "vpn serasa"
                        },
                        {
                            "CidrIp": "10.99.8.64/26",
                            "Description": "internal aws"
                        },
                        {
                            "CidrIp": "10.99.85.0/24",
                            "Description": "internal subnet"
                        },
                        {
                            "CidrIp": "100.64.0.0/16",
                            "Description": "internal k8s"
                        }
                    ],
                    "Ipv6Ranges": [],
                    "PrefixListIds": [],
                    "ToPort": 9092,
                    "UserIdGroupPairs": []
                }
            ],
...
}

##### Listar CIDRs das VPCs para solicitar liberação do firewall
aws ec2 describe-vpcs --profile datahubdev 
{
    "Vpcs": [
        {
            "CidrBlock": "10.121.13.0/24",
...
            "CidrBlockAssociationSet": [
                {
                    "AssociationId": "vpc-cidr-assoc-0608bfd8becb5cf93",
                    "CidrBlock": "10.121.13.0/24",
                    "CidrBlockState": {
                        "State": "associated"
                    }
                },
...
                }

aws ec2 describe-vpcs --profile dataservicesdev
{
    "Vpcs": [
        {
            "CidrBlock": "10.99.8.64/26",
...
            "CidrBlockAssociationSet": [
                {
                    "AssociationId": "vpc-cidr-assoc-0c728d740535ac025",
                    "CidrBlock": "10.99.8.64/26",
                    "CidrBlockState": {
                        "State": "associated"
                    }
                },
                {
                    "AssociationId": "vpc-cidr-assoc-053c8086d6d9ee2fc",
                    "CidrBlock": "100.64.0.0/16",
                    "CidrBlockState": {
                        "State": "associated"
                    }
                },
                {
                    "AssociationId": "vpc-cidr-assoc-05631aa81dd06dbbd",
                    "CidrBlock": "10.99.85.0/24",
                    "CidrBlockState": {
                        "State": "associated"
                    }
                },
                {
                    "AssociationId": "vpc-cidr-assoc-08f530a64f7b6da1c",
                    "CidrBlock": "100.65.0.0/16",
                    "CidrBlockState": {
                        "State": "associated"
                    }
                }
 
 
aws ec2 describe-vpcs --profile dataservicesdev --query "Vpcs[].CidrBlock"
[
    "10.99.8.64/26"
]
aws ec2 describe-vpcs --profile datahubdev --query "Vpcs[].CidrBlock"
[
    "10.121.13.0/24"
]

### Ajustar role na conta do Mercantil para a aplicação usar o MSK na conta de destino
#### Entender qual a ROLE 
Falei com o usuário e como ele vai usar o EMR, ele informou que a ROLE que ele usa é a BURoleForPositivoMercantil

#### Ajustar permissões na BUPolicyForPositivoMercantil e incluir:
{
  "Effect": "Allow",
  "Action": "sts:AssumeRole",
  "Resource": "arn:aws:iam::530914589075:role/BURoleForMSKCrossAccountMercantil"
}

### Ajustar role na conta DataServices para o Assume Role
#### Criar a Role BURoleForMSKCrossAccountMercantil
Trust:
{
  "Effect": "Allow",
  "Principal": {
    "AWS": "arn:aws:iam::730335661246:role/BURoleForPositivoMercantil"
  },
  "Action": "sts:AssumeRole"
}

Policy:
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ClusterMetadata",
      "Effect": "Allow",
      "Action": [
        "kafka:DescribeCluster",
        "kafka:DescribeClusterV2",
        "kafka:GetBootstrapBrokers"
      ],
      "Resource": "arn:aws:kafka:sa-east-1:530914589075:cluster/ds-msk-dev/5918cb83-9fef-47b8-afcb-6f15d88e0d06-3"
    },
    {
      "Sid": "KafkaConnectToCluster",
      "Effect": "Allow",
      "Action": [
        "kafka-cluster:Connect"
      ],
      "Resource": "arn:aws:kafka:sa-east-1:530914589075:cluster/ds-msk-dev/5918cb83-9fef-47b8-afcb-6f15d88e0d06-3"
    },
    {
      "Sid": "ListAndUseTopics",
      "Effect": "Allow",
      "Action": [
        "kafka-cluster:DescribeTopic",
        "kafka-cluster:ReadData",
        "kafka-cluster:WriteData",
        "kafka-cluster:WriteDataIdempotently"
      ],
      "Resource": "arn:aws:kafka:sa-east-1:530914589075:topic/ds-msk-dev/5918cb83-9fef-47b8-afcb-6f15d88e0d06-3/*"
    },
    {
      "Sid": "ListAndUseConsumerGroups",
      "Effect": "Allow",
      "Action": [
        "kafka-cluster:DescribeGroup",
        "kafka-cluster:AlterGroup"
      ],
      "Resource": "arn:aws:kafka:sa-east-1:530914589075:group/ds-msk-dev/5918cb83-9fef-47b8-afcb-6f15d88e0d06-3/*"
    }
  ]
}

#### Comandos para ajustar a policy na Datahub-dev
aws iam list-attached-role-policies \
  --role-name BUPolicyForPositivoMercantil \
  --profile datahubdev

{
    "AttachedPolicies": [
...
        {
            "PolicyName": "BUPolicyForPositivoMercantil",
            "PolicyArn": "arn:aws:iam::730335661246:policy/BUPolicyForPositivoMercantil"
        },
...
    ]
}

aws iam get-policy \
  --policy-arn arn:aws:iam::730335661246:policy/BUPolicyForPositivoMercantil \
  --profile datahubdev      
{
    "Policy": {
        "PolicyName": "BUPolicyForPositivoMercantil",
        "PolicyId": "ANPA2UC3FZS7C67HY5N5O",
        "Arn": "arn:aws:iam::730335661246:policy/BUPolicyForPositivoMercantil",
        "Path": "/",
        "DefaultVersionId": "v30",
 ...
    }
}

aws iam get-policy-version \
  --policy-arn arn:aws:iam::730335661246:policy/BUPolicyForPositivoMercantil \
  --version-id v30 \
  --profile datahubdev \
  --query "PolicyVersion.Document"

Gerei um arquivo policy-datahubdev.json

aws iam delete-policy-version \
--policy-arn arn:aws:iam::730335661246:policy/BUPolicyForPositivoMercantil \
--version-id v26 \
--profile datahubdev

aws iam create-policy-version \
--policy-arn arn:aws:iam::730335661246:policy/BUPolicyForPositivoMercantil \
--policy-document file://policy-datahubdev.json \ 
--set-as-default \
--profile datahubdev
{
    "PolicyVersion": {
        "VersionId": "v31",
        "IsDefaultVersion": true,
        "CreateDate": "2026-02-24T20:30:43+00:00"
    }
}

# Criar Role e Policy na conta Dataservices Dev

