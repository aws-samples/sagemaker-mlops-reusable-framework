#Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. SPDX-License-Identifier: MIT-0
resource "aws_iam_role" "sagemaker_role" {
  assume_role_policy = jsonencode(
    {
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = [
          "firehose.amazonaws.com",
          "glue.amazonaws.com",
          "apigateway.amazonaws.com",
          "lambda.amazonaws.com",
          "events.amazonaws.com",
          "states.amazonaws.com",
          "sagemaker.amazonaws.com",
          "cloudformation.amazonaws.com",
          "codebuild.amazonaws.com",
          "codepipeline.amazonaws.com"
        ]
          }
        },
      ]
      Version = "2012-10-17"
    }
  )
  force_detach_policies = false
  max_session_duration  = 3600
  name                  = "tf-sagemaker-role-${var.environment}-2"
  path                  = "/service-role/"
  tags                  = {}
}

resource "aws_iam_policy" "sagemaker_mlops_policy" {
  description = "Policy used in trust"
  name        = "tf-sagemaker-policy-${var.environment}-2"
  path        = "/service-role/"
  policy = jsonencode(
    {
      Statement = [
        {
          Action : [
            "iam:PassRole"
          ],
          Resource : "*",
          Effect : "Allow"
        },
        {
            "Action": [
                "s3:GetBucketAcl",
                "s3:GetBucketCors",
                "s3:GetBucketLocation",
                "s3:GetObjectVersion",
                "s3:PutBucketCors",
                "s3:AbortMultipartUpload",
                "s3:CreateBucket",
                "s3:DeleteBucket",
                "s3:PutObjectAcl",
                "s3:List*"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::*",
                "arn:aws:s3:::*/*"
            ]
        },
        {
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject",
                "s3:GetObjectVersion"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::*/*"
            ]
        },
       
        {
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Effect" : "Allow",
          "Resource" : "arn:aws:logs:*"
        },

        {
            "Action": [
                "codepipeline:StartPipelineExecution"
            ],
            "Resource": "arn:aws:codepipeline:*:*:*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "events:DeleteRule",
                "events:DescribeRule",
                "events:PutRule",
                "events:PutTargets",
                "events:RemoveTargets"
            ],
            "Resource": [
                "arn:aws:events:*:*:rule/*"
            ],
            "Effect": "Allow"
        },
        {
            "Effect": "Allow",
            "Action": [
                "sagemaker:*"
            ],
            "NotResource": [
                "arn:aws:sagemaker:*:*:domain/*",
                "arn:aws:sagemaker:*:*:user-profile/*",
                "arn:aws:sagemaker:*:*:app/*",
                "arn:aws:sagemaker:*:*:flow-definition/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "sagemaker:CreatePresignedDomainUrl",
                "sagemaker:DescribeDomain",
                "sagemaker:ListDomains",
                "sagemaker:DescribeUserProfile",
                "sagemaker:ListUserProfiles",
                "sagemaker:*App",
                "sagemaker:ListApps"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "sagemaker:*",
            "Resource": [
                "arn:aws:sagemaker:*:*:flow-definition/*"
            ],
            "Condition": {
                "StringEqualsIfExists": {
                    "sagemaker:WorkteamType": [
                        "private-crowd",
                        "vendor-crowd"
                    ]
                }
            }
        },
        {
            "Action": [
                "cloudformation:CreateChangeSet",
                "cloudformation:CreateStack",
                "cloudformation:DescribeChangeSet",
                "cloudformation:DeleteChangeSet",
                "cloudformation:DeleteStack",
                "cloudformation:DescribeStacks",
                "cloudformation:ExecuteChangeSet",
                "cloudformation:SetStackPolicy",
                "cloudformation:UpdateStack"
            ],
            "Resource": "arn:aws:cloudformation:*:*:stack/*",
            "Effect": "Allow"
        },
        {
            "Action": [
                "codebuild:BatchGetBuilds",
                "codebuild:StartBuild"
            ],
            "Resource": [
                "arn:aws:codebuild:*:*:project/*",
                "arn:aws:codebuild:*:*:build/*"
            ],
            "Effect": "Allow"
        },
        {
            "Action": [
                 "states:DescribeExecution",
                "states:DescribeStateMachine",
                "states:DescribeStateMachineForExecution",
                "states:GetExecutionHistory",
                "states:ListExecutions",
                "states:ListTagsForResource",
                "states:StartExecution",
                "states:StopExecution",
                "states:TagResource",
                "states:UntagResource",
                "states:UpdateStateMachine"
            ],
            "Resource": [
                "arn:aws:states:*:*:statemachine:*",
                "arn:aws:states:*:*:execution:*:*"
            ],
            "Effect": "Allow"
        },
       
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:GetRandomPassword",
                "secretsmanager:GetResourcePolicy",
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret",
                "secretsmanager:ListSecretVersionIds",
                "secretsmanager:ListSecrets"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:CreateBucket",
                "s3:GetBucketLocation",
                "s3:ListBucket",
                "s3:ListAllMyBuckets",
                "s3:GetBucketCors",
                "s3:PutBucketCors"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetBucketAcl",
                "s3:PutObjectAcl"
            ],
            "Resource": [
                "arn:aws:s3:::*",
                "arn:aws:s3:::*",
                "arn:aws:s3:::*"
            ]
        },
        {
            "Action": [
                "ecr:BatchCheckLayerAvailability",
                "ecr:BatchGetImage",
                "ecr:Describe*",
                "ecr:GetAuthorizationToken",
                "ecr:GetDownloadUrlForLayer"
            ],
            "Resource": "*",
            "Effect": "Allow"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ecr:BatchDeleteImage",
                "ecr:CompleteLayerUpload",
                "ecr:CreateRepository",
                "ecr:DeleteRepository",
                "ecr:InitiateLayerUpload",
                "ecr:PutImage",
                "ecr:UploadLayerPart"
            ],
            "Resource": [
                "arn:aws:ecr:*:*:repository/*"
            ]
        },
        {
            "Action": "iam:CreateServiceLinkedRole",
            "Effect": "Allow",
            "Resource": "arn:aws:iam::*:role/aws-service-role/sagemaker.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_SageMakerEndpoint",
            "Condition": {
                "StringLike": {
                    "iam:AWSServiceName": "sagemaker.application-autoscaling.amazonaws.com"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": "iam:CreateServiceLinkedRole",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:AWSServiceName": "robomaker.amazonaws.com"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "sns:Subscribe",
                "sns:CreateTopic"
            ],
            "Resource": [
                "arn:aws:sns:*:*:*",
                "arn:aws:sns:*:*:*",
                "arn:aws:sns:*:*:*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:PassRole"
            ],
            "Resource": "arn:aws:iam::*:role/*",
        }
        
      ]
      Version = "2012-10-17"
    }
  )
}


resource "aws_iam_role_policy_attachment" "gitlab_mlops_policy_attachment" {
  role       = aws_iam_role.sagemaker_role.name
  policy_arn = aws_iam_policy.sagemaker_mlops_policy.arn
}
