# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. SPDX-License-Identifier: MIT-0
resource "aws_iam_role" "lambda_role" {
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = [
 
          "lambda.amazonaws.com"
          
        ]
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
  force_detach_policies = false
  max_session_duration  = 3600
  name                  = "tf-lambda-role-${var.environment}-02"
  path                  = "/service-role/"
  tags                  = {}
}

resource "aws_iam_policy" "lambda_policy" {
  description = "Policy used in trust relationship with CodeBuild (${var.environment})"
  name        = "tf-lambda-policy-${var.environment}-02"
  path        = "/service-role/"
  policy = jsonencode(
      {
      Statement = [
          {
            "Action": [
                "logs:PutLogEvents",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:AssociateKmsKey",
                "logs:CreateLogGroup"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:logs:us-east-1:*:log-group:/aws/lambda/*",
                "arn:aws:logs:us-east-1:*:log-group:/ssm/session-logs:log-stream:*"
            ]
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
                "glue:Cancel*",
                "glue:Create*",
                "glue:Batch*",
                "glue:Get*",
                "glue:ImportCatalogToGlue",
                "glue:List*",
                "glue:Put*",
                "glue:Update*",
                "glue:RegisterSchemaVersion",
                "glue:SearchTables",
                "glue:Start*",
                "glue:TagResource",
                "glue:QuerySchemaVersionMetadata"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:glue:us-east-1:*:devEndpoint/*",
                "arn:aws:glue:us-east-1:*:database/*",
                "arn:aws:glue:us-east-1:*:catalog",
                "arn:aws:glue:us-east-1:*:job/*",
                "arn:aws:glue:us-east-1:*:table/*/*",
                "arn:aws:glue:us-east-1:*:registry/*",
                "arn:aws:glue:us-east-1:*:connection/*"
            ]
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
                "ec2:CreateNetworkInterface"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": [
                "states:Get*",
                "states:StartExecution"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:states:us-east-1:*:stateMachine:*",
                "arn:aws:states:us-east-1:*:execution:*:*"
            ]
        },
        {
            "Action": [
                "sqs:ReceiveMessage",
                "sqs:DeleteMessage",
                "sqs:SendMessage",
                "sqs:SendMessageBatch",
                "sqs:Get*"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:sqs:us-east-1:*:*"
            ]
        },
        {
            "Action": [
                "secretsmanager:Get*",
                "secretsmanager:DescribeSecret",
                "secretsmanager:ListSecrets"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:secretsmanager:us-east-1:*:secret:*-??????",
                "arn:aws:secretsmanager:us-east-1:*:secret:*"
            ]
        }
      ]
      Version = "2012-10-17"
    }
  )
}


resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}
