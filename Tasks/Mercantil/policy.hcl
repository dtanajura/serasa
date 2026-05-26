locals {
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "S3ReadAccessAllBuckets",
        "Effect" : "Allow",
        "Action" : [
          "s3:Get*",
          "s3:List*",
          "s3:Describe*",
          "s3:CreateBucket",
          "s3:Put*",
          "eks:DescribeCluster",
          "eks:ListClusters",
          "athena:Start*",
          "athena:Get*",
          "athena:List*"
        ],
        "Resource" : "*"
      },
      {
        "Sid": "EmrOnEc2CoreOps",
        "Effect": "Allow",
        "Action": [
          "elasticmapreduce:RunJobFlow",
          "elasticmapreduce:ListClusters",
          "elasticmapreduce:DescribeCluster",
          "elasticmapreduce:ListSteps",
          "elasticmapreduce:AddJobFlowSteps",
          "elasticmapreduce:TerminateJobFlows",
          "elasticmapreduce:ModifyCluster",
          "elasticmapreduce:DescribeStep",
          "elasticmapreduce:ListInstances"
        ],
        "Resource": "*"
      },
      {
        "Sid": "Ec2DescribeForEmrPlacement",
        "Effect": "Allow",
        "Action": [
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          "ec2:DescribeRouteTables",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeKeyPairs"
        ],
        "Resource": "*"
      },
      {
        "Sid": "AllowPassOnlyEmrServiceRoles",
        "Effect": "Allow",
        "Action": "iam:PassRole",
        "Resource": "*",
        "Condition": {
          "StringEquals": {
            "iam:PassedToService": "elasticmapreduce.amazonaws.com"
          }
        }
      },
      { "Sid": "ReadDbSecret",
        "Effect": "Allow",
        "Action": [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        "Resource": "arn:aws:secretsmanager:sa-east-1:146737708860:secret:rds!cluster-b25f56e5-a7d8-4500-8826-b3f29bc91b82-gytd44"
      },
      { "Sid": "RdsDescribe",
        "Effect": "Allow",
        "Action": [
          "rds:DescribeDBClusters",
          "rds:DescribeDBInstances"
        ],
        "Resource": "*"
      }

    ]
  })
}
