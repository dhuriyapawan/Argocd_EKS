############################################
# S3 Bucket (Terraform Backend)
############################################
resource "aws_s3_bucket" "terraform_state" {
  count  = var.create_bucket ? 1 : 0
  bucket = var.bucket_name

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "terraform-state-bucket"
    Environment = "terraform-backend"
  }
}

############################################
# Block Public Access (REQUIRED)
############################################
resource "aws_s3_bucket_public_access_block" "block_public" {
  count  = var.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.terraform_state[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

############################################
# Bucket Ownership Controls (Modern Standard)
############################################
resource "aws_s3_bucket_ownership_controls" "ownership" {
  count  = var.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.terraform_state[0].id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

############################################
# Versioning (CRITICAL for Terraform State)
############################################
resource "aws_s3_bucket_versioning" "versioning" {
  count  = var.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.terraform_state[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

############################################
# Server-Side Encryption (KMS Recommended)
############################################
resource "aws_kms_key" "terraform_state" {
  count                   = var.create_bucket ? 1 : 0
  description             = "KMS key for Terraform state bucket"
  deletion_window_in_days = 30
  enable_key_rotation     = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  count  = var.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.terraform_state[0].id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.terraform_state[0].arn
      sse_algorithm     = "aws:kms"
    }
  }
}

############################################
# Enforce TLS (HTTPS Only)
############################################
resource "aws_s3_bucket_policy" "require_tls" {
  count  = var.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.terraform_state[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnforceTLS"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.terraform_state[0].arn,
          "${aws_s3_bucket.terraform_state[0].arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

############################################
# Lifecycle Rules
############################################
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  count  = var.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.terraform_state[0].id

  rule {
    id     = "terraform-state-lifecycle"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}