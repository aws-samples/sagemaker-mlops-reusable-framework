# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. SPDX-License-Identifier: MIT-0
resource "aws_s3_object" "etl-job-script" {
  bucket      = var.bucket
  key         = "terraform-demo/glue_scripts/test1.py"
  source      = join("/", [path.module, "glue/test1.py"])
  source_hash = filemd5(join("/", [path.module, "glue/test1.py"]))
}
 
resource "aws_glue_job" "oracle-glue-test" {
  name                   = join("-", [var.prefix, var.environment, "ml-stepfunc-test2"])
  role_arn               = aws_iam_role.glue_role.arn

 
  glue_version      = "3.0"
  timeout           = 360
  max_retries       = 0
  worker_type       = "G.1X"
  number_of_workers = 10
 
  default_arguments ={
    "--extra-jars" = " osdt_core.jar",
  }
 
  command {
    script_location = join("", ["s3://", var.bucket, "/", "terraform-demo/glue_scripts/test1.py"])
    python_version  = "3"
  }
 
  execution_property {
    max_concurrent_runs = 2
  }
}
 