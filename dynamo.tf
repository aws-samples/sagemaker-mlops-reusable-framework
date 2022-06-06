resource "aws_dynamodb_table" "ml-train-pipeline-attribute-ds" {
  name         = join("-", [var.prefix, var.environment, "ml-pipeline-attribute-ds2"])
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "name"
 
  attribute {
    name = "name"
    type = "S"
  }
 
}
 
resource "aws_dynamodb_table_item" "mltrain-pipeline-items" {
  for_each    = local.dynamodb_items
  table_name  = aws_dynamodb_table.ml-train-pipeline-attribute-ds.name
  hash_key    = aws_dynamodb_table.ml-train-pipeline-attribute-ds.hash_key
 
  item = templatefile(join("/", [local.dynamodb_items_path, each.value]), {})
  #item=templatefile(filemd5(join("/", [local.dynamodb_items_path, each.value])),{})
}
 
 
locals {
    dynamodb_items_path  = join("/", [path.module, "dynamodb_items"])
    dynamodb_items       = fileset(local.dynamodb_items_path, "**")
}

## upload items to S3
resource "aws_s3_object" "dynamodb_items" {
  for_each    = local.dynamodb_items
  source      = join("/", [local.dynamodb_items_path,each.value])
  bucket      = var.bucket
  key         = "terraform-demo/dynamodb-items/${each.value}"
  source_hash = filemd5(join("/", [local.dynamodb_items_path,each.value]))
}