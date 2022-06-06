# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. SPDX-License-Identifier: MIT-0

data "archive_file" "routing" {
    type        = "zip"
    source_dir  = "${path.module}/lambda/routing/src"
    output_path = "${path.module}/lambda/routing/bin/lambda.zip"
}
 
resource "aws_lambda_function" "routing_lambda" {
    function_name       = join("-", [var.prefix, var.environment, "routing-common2"])
    role                = aws_iam_role.lambda_role.arn
    memory_size         = 512
    runtime             = "python3.8"
    timeout             = 300
    handler             = "lambda_function.lambda_handler"
    filename            = data.archive_file.routing.output_path
    source_code_hash    = data.archive_file.routing.output_base64sha256
 
    environment {
        variables = {
            account_id  = var.account_id
            env         = var.environment
            prefix      = var.prefix
            region      = var.region
        }
    }
}
 
