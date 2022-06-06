# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. SPDX-License-Identifier: MIT-0
resource "aws_cloudwatch_log_group" "ml-aws-sfn" {
  name              = join("-", compact(["/aws/states/${var.prefix}", var.environment, "ml-train-pipeline-common2"]))
  retention_in_days = 365

}
 
# State Machine
resource "aws_sfn_state_machine" "ml-aws-sfn" {
  name       = join("-", compact([var.prefix, var.environment, "ml-train-pipeline-common2"]))
  role_arn   = aws_iam_role.states_role.arn
  definition = templatefile("${path.module}/statemachines/this.json", {
    region                = var.region
    account_id            = var.account_id
    environment           = var.environment
  })
 
  logging_configuration {
    log_destination        = "${aws_cloudwatch_log_group.ml-aws-sfn.arn}:*"
    include_execution_data = true
    level                  = "ALL"
  }

}
