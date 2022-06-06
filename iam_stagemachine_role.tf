# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. SPDX-License-Identifier: MIT-0
resource "aws_iam_role" "states_role" {
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = [
  
          "states.amazonaws.com"
         
        ]
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
  force_detach_policies = false
  max_session_duration  = 3600
  name                  = "tf-states-role-${var.environment}-2"
  path                  = "/service-role/"
  tags                  = {}
}

resource "aws_iam_policy" "states_policy" {
  description = "Policy used in trust relationship with CodeBuild (${var.environment})"
  name        = "tf-states-policy-${var.environment}-2"
  path        = "/service-role/"
  policy = jsonencode(
    {
      Statement = [
        {
            "Action": [
                "sagemaker:DescribeTrainingJob",
                "sagemaker:DescribeTransformJob",
                "sagemaker:ListTags",
                "sagemaker:StopTransformJob",
                "sagemaker:StopTrainingJob",
                "sagemaker:CreateTrainingJob",
                "sagemaker:CreateTransformJob"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:sagemaker:us-east-1:*:transform-job/*",
                "arn:aws:sagemaker:us-east-1:*:training-job/*"
            ]
        },
        {
            "Action": [
                "sagemaker:CreateProcessingJob",
                "sagemaker:DescribeProcessingJob",
                "sagemaker:StopProcessingJob"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:sagemaker:us-east-1:*:processing-job/*"
        },
        {
            "Action": "sagemaker:CreateModel",
            "Effect": "Allow",
            "Resource": "arn:aws:sagemaker:us-east-1:*:model/*"
        },
        {
            "Action": [
                "events:PutTargets",
                "events:DescribeRule",
                "events:PutRule"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:events:us-east-1:*:rule/*"
            ]
        },
        {
            "Action": "lambda:InvokeFunction",
            "Effect": "Allow",
            "Resource": "arn:aws:lambda:us-east-1:*:function:*"
        },
        {
            "Action": [
                "glue:StartJobRun",
                "glue:GetJobRuns",
                "glue:GetJobRun",
                "glue:BatchStopJobRun"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:glue:us-east-1:*:job/*"
        },
        {
            "Action": "sns:Publish",
            "Effect": "Allow",
            "Resource": "arn:aws:sns:us-east-1:*:*"
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
                "logs:PutLogEvents",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "logs:AssociateKmsKey",
                "logs:CreateLogGroup"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:logs:us-east-1:*:log-group:/aws/states/*",
                "arn:aws:logs:us-east-1:*:log-group:/ssm/session-logs:log-stream:*"
            ]
        },
        {
            "Action": [
                "secretsmanager:DescribeSecret",
                "secretsmanager:TagResource",
                "secretsmanager:List*",
                "secretsmanager:GetSecretValue",
                "secretsmanager:ValidateResourcePolicy"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:secretsmanager:us-east-1:*:secret:*-??????",
                "arn:aws:secretsmanager:us-east-1:*:secret:*"
            ]
        },
        {
            "Action": [
                "logs:CreateLogDelivery",
                "logs:GetLogDelivery",
                "logs:UpdateLogDelivery",
                "logs:DeleteLogDelivery",
                "logs:ListLogDeliveries",
                "logs:PutResourcePolicy",
                "logs:DescribeResourcePolicies",
                "logs:DescribeLogGroups"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": [
                "sagemaker:CreateHyperParameterTuningJob",
                "sagemaker:DescribeHyperParameterTuningJob",
                "sagemaker:StopHyperParameterTuningJob"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:sagemaker:us-east-1:*:hyper-parameter-tuning-job/*"
        },
          {
            "Action": [
                "sagemaker:CreateEndpointConfig",
                "sagemaker:CreateEndpoint",
                    "sagemaker:CreateModelPackage",
                    "sagemaker:DeleteModel",
                    "sagemaker:CreateEndpointConfig",
                    "sagemaker:DescribeEndpointConfig",
                    "sagemaker:DeleteEndpoint",
                    "sagemaker:DescribeEndpoint",
                    "sagemaker:InvokeEndpoint",
                    "sagemaker:UpdateEndpoint"
               
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:sagemaker:us-east-1:*:*"
        },
        {
            "Action": [
                "iam:PassRole"
            ],
            "Condition": {
                "StringEquals": {
                    "iam:PassedToService": "sagemaker.amazonaws.com"
                }
            },
            "Effect": "Allow",
            "Resource": [
                "arn:aws:iam::*:role/*"
            ]
        }
      ]
      Version = "2012-10-17"
    }
  )
}


resource "aws_iam_role_policy_attachment" "states_policy_attachment" {
  role       = aws_iam_role.states_role.name
  policy_arn = aws_iam_policy.states_policy.arn
}
