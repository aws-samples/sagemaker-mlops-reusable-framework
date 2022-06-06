# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. SPDX-License-Identifier: MIT-0
resource "aws_sns_topic" "pipeline_success_topic"{
  name              = join("-", compact([var.prefix, var.environment, "pl-success-topic2"]))

}
 
resource "aws_sns_topic" "pipeline_error_topic"{
  name              = join("-", compact([var.prefix, var.environment, "pl-error-topic2"]))

}
 
resource "aws_sns_topic_policy" "pipeline_success_topic_policy" {
  arn     = aws_sns_topic.pipeline_success_topic.arn
  policy  = data.aws_iam_policy_document.preprod_sns_topic_policy.json
}
 
data "aws_iam_policy_document" "preprod_sns_topic_policy" {
  statement {
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]
 
    effect = "Allow"
 
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
 
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"
      values = [
        var.account_id
      ]
    }
 
    resources = [
      aws_sns_topic.pipeline_success_topic.arn,
    ]
  }
}