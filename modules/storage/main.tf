resource "aws_s3_bucket" "this" {
  #checkov:skip=CKV2_AWS_62:Event notifications require a workload-specific destination that this foundation does not own.
  #checkov:skip=CKV_AWS_18:Access logging requires a separate log archive bucket and is documented as a future extension.
  #checkov:skip=CKV_AWS_144:Cross-region replication adds storage and transfer cost beyond this environment's recovery objective.
  #checkov:skip=CKV_AWS_145:SSE-S3 encrypts at rest without a paid KMS key; KMS is an optional stricter control.
  bucket_prefix = "${var.name}-encrypted-"
  force_destroy = var.force_destroy
  tags          = merge(var.tags, { Name = "${var.name}-encrypted-storage" })
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    id     = "expire-noncurrent-versions"
    status = "Enabled"
    filter {}
    abort_incomplete_multipart_upload { days_after_initiation = 7 }
    noncurrent_version_expiration { noncurrent_days = 30 }
  }
  depends_on = [aws_s3_bucket_versioning.this]
}
