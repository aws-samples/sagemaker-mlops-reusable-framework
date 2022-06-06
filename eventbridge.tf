# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. SPDX-License-Identifier: MIT-0
resource "aws_cloudwatch_event_rule" "cron_rule" {
    count               = contains(["dev"], var.environment) ? 1 : 0
    name                = "${var.prefix}-cron-rule2"
    description         = "ML cron rule"
  
    schedule_expression = "cron(0 14 ? * SAT *)"
}
 
resource "aws_cloudwatch_event_target" "cron_event_target" {
    count       = contains(["dev", "uat"], var.environment) ? 1 : 0
    rule        = aws_cloudwatch_event_rule.cron_rule[count.index].name
    target_id   = "cronTrigger"
    arn         = aws_lambda_function.routing_lambda.arn
 
    input_transformer {
        input_template = <<JSON
        {
            "Records": [
                {
                    "body": {
                        "consumption_pipeline_name": "demo-dev-domain-cal-house-price",
                        "dataset_date": <aws.events.event.ingestion-time>,
                        "event_source": "event-bridge"
                    },
                    "eventSource": "event-bridge"
                }
            ]
        }
        JSON
    }
}
 
resource "aws_lambda_permission" "cron_permission" {
  count         = contains(["dev"], var.environment) ? 1 : 0
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.routing_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cron_rule[count.index].arn
}


resource "aws_cloudwatch_event_rule" "s3_rule" {
  count       = contains(["dev"], var.environment) ? 1 : 0
  name        = "capture-inputcode-s3-event2"
  description = "Capture each AWS S3 event"
 
  event_pattern = <<EOF
  {
  "source": [
        "aws.s3"
    ],
    "detail-type": [
        "Object Created"
    ],
 
    "detail": {
        "bucket": {
            "name": [
                "${var.bucket}"
            ]
        },
        "object" : {
            "key" : [{"prefix" : "terraform-demo/stepfunc/input/"}]
        }
    }
  }
  EOF
}
 
resource "aws_lambda_permission" "s3_permission" {
  count         = contains(["dev"], var.environment) ? 1 : 0
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.routing_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.s3_rule[count.index].arn
}

resource "aws_cloudwatch_event_target" "s3_event_target" {
    count       = contains(["dev", "uat"], var.environment) ? 1 : 0
    rule        = aws_cloudwatch_event_rule.s3_rule[count.index].name
    target_id   = "s3Trigger"
    arn         = aws_lambda_function.routing_lambda.arn
 
    input_transformer {
        input_template = <<JSON
        {
            "Records": [
                {
                    "body": {
                        "consumption_pipeline_name": "demo-dev-domain-cal-house-price",
                        "dataset_date": <aws.events.event.ingestion-time>,
                        "event_source": "event-bridge"
                    },
                    "eventSource": "event-bridge"
                }
            ]
        }
        JSON
    }
}