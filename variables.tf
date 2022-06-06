# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. SPDX-License-Identifier: MIT-0
variable "environment" {
  description = "Deployment environment"
  default     = "dev"
}
variable "prefix" {
  description = "prefix"
  default     = "demo"
}

variable "account_id" {
  description = "AWS ID"
  default     = "<your id>"
}

variable "bucket" {
  description = "S3 Bucket for storing artifacts"
  default     = "<your bucket>"
}

variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}



