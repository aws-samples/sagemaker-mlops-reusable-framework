# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. SPDX-License-Identifier: MIT-0
locals {
  model_path  = "${path.module}/sagemaker-artifacts"
  model_files = fileset(local.model_path, "**")
}
 
# upload artifacts to S3
resource "aws_s3_object" "sagemaker_artifacts" {
  for_each    = local.model_files
  source      = join("/", [local.model_path,each.value])
  bucket      = var.bucket
  key         = "${each.value}"
  source_hash = filemd5(join("/", [local.model_path,each.value]))
}
 
#Enable EventBridge 
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = var.bucket
  eventbridge = true
}
