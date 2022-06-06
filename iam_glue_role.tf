# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. SPDX-License-Identifier: MIT-0
resource "aws_iam_role" "glue_role" {
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = [
          "glue.amazonaws.com",
        ]
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
  force_detach_policies = false
  max_session_duration  = 3600
  name                  = "tf-glue-role-${var.environment}-2"
  path                  = "/service-role/"
  tags                  = {}
}

resource "aws_iam_policy" "glue_policy" {
  description = "Policy used in trust relationship with CodeBuild (${var.environment})"
  name        = "tf-glue-policy-${var.environment}-2"
  path        = "/service-role/"
  policy = jsonencode(
    {
      Statement = [
       {
            "Action": [
                "dynamodb:Scan",
                "dynamodb:Query",
                "dynamodb:Get*",
                "dynamodb:DescribeTable",
                "dynamodb:BatchGetItem"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:dynamodb:us-east-1:*:table/*"
            ]
        },
        {
            "Action": [
                "dynamodb:UpdateItem",
                "dynamodb:PutItem",
                "dynamodb:DeleteItem",
                "dynamodb:BatchWriteItem"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:dynamodb:us-east-1:*:table/*"
            ]
        },
        {
            "Action": [
                "glue:Batch*",
                "glue:CheckSchemaVersionValidity",
                "glue:Create*",
                "glue:Delete*",
                "glue:Get*",
                "glue:ImportCatalogToGlue",
                "glue:List*",
                "glue:Put*",
                "glue:QuerySchemaVersionMetadata",
                "glue:RegisterSchemaVersion",
                "glue:RemoveSchemaVersionMetadata",
                "glue:ResetJobBookmark",
                "glue:SearchTables",
                "glue:Start*",
                "glue:Stop*",
                "glue:TagResource",
                "glue:UntagResource",
                "glue:Update*"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:glue:us-east-1:*:database/*",
                "arn:aws:glue:us-east-1:*:catalog",
                "arn:aws:glue:us-east-1:*:table/*/*",
                "arn:aws:glue:us-east-1:*:userDefinedFunction/*/*",
                "arn:aws:glue:us-east-1:*:crawler/*",
                "arn:aws:glue:us-east-1:*:tableVersion/*/*/*",
                "arn:aws:glue:us-east-1:*:job/*",
                "arn:aws:glue:us-east-1:*:workflow/*",
                "arn:aws:glue:us-east-1:*:connection/*",
                "arn:aws:glue:us-east-1:*:devEndpoint/*"
            ],
            "Sid": "GlueAccess"
        },
        {
            "Action": [
                "logs:PutLogEvents",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:AssociateKmsKey"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:logs:us-east-1:*:log-group:/aws-glue/*"
        },
        {
            "Action": [
                "logs:CreateLogGroup"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:logs:us-east-1:*:log-group:/aws-glue/jobs/*",
                "arn:aws:logs:us-east-1:*:log-group:/aws-glue/python-jobs/*",
                "arn:aws:logs:us-east-1:*:log-group:/aws-glue/testconnection/*"
            ]
        },
        {
            "Action": [
                "ec2:DescribeVpcs",
                "ec2:DescribeVpcEndpoints",
                "ec2:DescribeSubnets",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeRouteTables",
                "ec2:DescribeVpcAttribute",
                "ec2:DeleteNetworkInterface",
                "ec2:CreateNetworkInterface",
                "ec2:CreateTags",
                "ec2:DeleteTags"
            ],
            "Effect": "Allow",
            "Resource": "*",
            "Sid": "glueNetworking"
        },
        {
            "Action": [
                "sns:Publish"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:sns:us-east-1:*:*"
        },
        {
            "Action": [
                "sqs:ReceiveMessage",
                "sqs:Get*",
                "sqs:List*",
                "sqs:DeleteMessage",
                "sqs:DeleteMessageBatch",
                "sqs:SendMessage",
                "sqs:SendMessageBatch"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:sqs:us-east-1:*:*"
        },
        {
            "Action": "s3:ListAllMyBuckets",
            "Effect": "Allow",
            "Resource": "arn:aws:s3:::*",
            "Sid": "GlueJobListAllBuckets"
        },
        {
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::*/*"

            ]
        },
        {
            "Action": [
                "s3:ListBucket",
                "s3:AbortMultipartUpload"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::*"
            ]
        },
        {
            "Action": [
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:Encrypt",
                "kms:DescribeKey",
                "kms:Decrypt",
                "kms:CreateGrant"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:kms:us-east-1:*:key/*"
            ],
            "Sid": ""
        },
        {
            "Action": [
                "ssm:GetParameter"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:ssm:us-east-1:*:*"
            ],
            "Sid": "SSMParameterReadAccess"
        },
        {
            "Action": [
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:secretsmanager:us-east-1:*:secret:*-??????",
                "arn:aws:secretsmanager:us-east-1:*:secret:*"
            ],
            "Sid": "AccessSecretValue"
        },
        {
            "Action": [
                "iam:PassRole"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:iam::*:role/*"
            ],
            "Sid": "PassRolestoAWSServices"
        }
      ]
      Version = "2012-10-17"
    }
  )
}


resource "aws_iam_role_policy_attachment" "glue_policy_attachment" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_policy.arn
}
