terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.19.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "example_bucket" {
  bucket = var.bucket_name

  tags = {
    Name        = var.bucket_name
    Environment = var.environment
  }
}

resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.example_bucket.id
  rule {
    object_ownership = var.bucket_ownership
  }
}

resource "aws_s3_bucket_acl" "example_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.example]
  bucket     = aws_s3_bucket.example_bucket.id
  acl        = var.bucket_acl
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.example_bucket.id
  versioning_configuration {
    status = var.enable_versioning
  }
}

# Upload an object
/*
resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.example_bucket.id
  key    = "test1.txt"
  acl    = var.bucket_acl
  source = "uploads/test1.txt"
  etag   = filemd5("uploads/test1.txt")
}
*/

# Upload multiple objects
resource "aws_s3_object" "object1" {
  for_each = fileset("uploads/", "*")
  bucket   = aws_s3_bucket.example_bucket.id
  key      = each.value
  source   = "uploads/${each.value}"
}