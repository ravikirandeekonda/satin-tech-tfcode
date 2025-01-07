#####################################
#S3 storage for Terraform State File#
#####################################

resource "aws_s3_bucket" "stdemos3stfile" {
  bucket = "st-demo-s3-stfile"
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.stdemos3stfile.bucket
  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_bucket_server_side_encryption_configuration" "bucketencrypttf" {
  bucket = aws_s3_bucket.stdemos3stfile.bucket

  rule {
    apply_server_side_encryption_by_default {
      //kms_master_key_id = aws_kms_key.mykey.arn
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "tfs3oc" {
  bucket = aws_s3_bucket.stdemos3stfile.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "tfs3acl" {
  depends_on = [aws_s3_bucket_ownership_controls.tfs3oc]

  bucket = aws_s3_bucket.stdemos3stfile.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "tfs3publicaccess" {
  bucket = aws_s3_bucket.stdemos3stfile.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

################
#DynamoDB-Table#
################

resource "aws_dynamodb_table" "stdydbstatelock" {
  name     = "st_tfstatelock"
  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  billing_mode = "PAY_PER_REQUEST"
  server_side_encryption {
    enabled = true
  }
}
