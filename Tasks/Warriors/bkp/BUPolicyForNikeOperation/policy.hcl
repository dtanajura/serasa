locals {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect =  "Allow"
        Action = [
          "glue:Get*",
          "glue:List*",
          "glue:SearchTables",
          "glue:CreateTable",
          "glue:CreateDatabase",
          "glue:CreateCrawler"
        ]
        Resource = ["*"]
      },
      {
        Effect =  "Allow"
        Action = [
          "cloudwatch:Get*",
          "cloudwatch:Describe*",
          "cloudwatch:List*"
        ]
        Resource = ["*"]
      },
      {
        Effect =  "Allow"
        Action = [
          "athena:Get*",
          "athena:List*",
          "athena:StartQueryExecution"
        ]
        Resource = ["*"]
      },
      {
        Effect =  "Allow"
        Action = [
          "sts:Get*"
        ]
        Resource = ["*"]
      },
      {
        Effect =  "Allow"
        Action = [
          "ce:Get*",
          "ce:List*",
          "ce:Describe*"
        ]
        Resource = ["*"]
      },
      {
        Effect =  "Allow"
        Action = [
          "airflow:Get*",
          "airflow:List*",
          "airflow:CreateWebLoginToken",
          "airflow:UpdateEnvironment"
        ]
        Resource = ["*"]
      },
      {
        Effect =  "Allow"
        Action = [
          "iam:PassRole",
          "iam:CreateRole",
          "iam:CreatePolicy",
          "iam:AttachRolePolicy",
          "iam:ListRoles",
          "iam:Get*",
          "iam:List*"
        ]
        Resource = ["*"]
      },
      {
        Effect =  "Allow"
        Action = [
          "athena:Get*",
          "athena:List*",
          "athena:StartQueryExecution"
        ]
        Resource = ["*"]
      },
      {
        Effect =  "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters"
        ]
        Resource = ["*"]
      },
      {
        Effect =  "Allow"
        Action = [
          "s3:Get*",
          "s3:List*",
          "s3:Describe*",
          "s3:Put*",
          "s3:Delete*",
          "s3:AbortMultipartUpload",
          "s3:CreateBucket"
        ]
        Resource = ["*"]
      },
      {
        Effect =  "Allow"
        Action = [
          "lambda:Get*",
          "lambda:List*",
          "lambda:Describe*",
          "lambda:PublishLayerVersion",
          "lambda:UpdateFunctionConfiguration",
          "lambda:CreateFunction",
          "lambda:GetLayerVersion",
          "lambda:InvokeFunction"
        ]
        Resource = ["*"]
      },
      {
        Effect =  "Allow"
        Action = [
          "logs:*"
        ]
        Resource = ["*"]
      },
      {
        Effect =  "Allow"
        Action = [
          "elasticmapreduce:TerminateJobFlows",
          "elasticmapreduce:Describe*",
          "elasticmapreduce:List*",
          "elasticmapreduce:Get*"
        ]
        Resource = ["*"]
      },
      {
        Effect =  "Allow"
        Action = [
          "ec2:Describe*",
          "ec2:List*",
          "ec2:Get*"
        ]
        Resource = ["*"]
      },
      {
        Effect =  "Allow"
        Action = [
          "rds:Describe*",
          "rds:List*",
          "rds:Get*"
        ]
        Resource = ["*"]
      },
      {
        Effect =  "Allow"
        Action = [
          "secretsmanager:ListSecrets",
          "secretsmanager:DescribeSecret"
        ]
        Resource = ["*"]
      },
      {
        Effect =  "Allow"
        Action = [
          "sqs:Get*",
          "sqs:List*",
          "sqs:ReceiveMessage"
        ]
        Resource = ["*"]
      },
      {
        Effect =  "Allow"
        Action = [
          "datasync:CreateLocationS3",
          "datasync:CreateTask",
          "datasync:DescribeLocation*",
          "datasync:DescribeTaskExecution",
          "datasync:ListLocations",
          "datasync:ListTaskExecutions",
          "datasync:DescribeTask",
          "datasync:CancelTaskExecution",
          "datasync:ListTasks",
          "datasync:StartTaskExecution"
        ]
        Resource = ["*"]
      },
      {
        Effect =  "Allow"
        Action = [
          "xray:*"
        ]
        Resource = ["*"]
      }
    ]
  })
}
