
locals {
  bucket_name = "${var.env}-${var.rev}-${var.name}-${random_pet.bucket.id}"
}

resource "aws_s3_bucket" "main" {
  bucket        = local.bucket_name
  force_destroy = true
  tags = {
    Env = var.env
    Rev = var.rev
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_id
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = "Enabled"
  }
}

# public_access_block
resource "aws_s3_bucket_public_access_block" "main" {
  bucket                  = aws_s3_bucket.main.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# lifecycle
resource "aws_s3_bucket_lifecycle_configuration" "main" {
  bucket     = aws_s3_bucket.main.id
  depends_on = [aws_s3_bucket_versioning.main]
  rule {
    id     = "rule-1"
    status = "Enabled"
    expiration {
      days = 10
    }
    abort_incomplete_multipart_upload {
      days_after_initiation = 10
    }
  }
}

# notification
resource "aws_s3_bucket_notification" "main" {
  bucket = aws_s3_bucket.main.id
  topic {
    topic_arn = aws_sns_topic.main.arn
    events    = ["s3:ObjectCreated:*"]
  }
}

resource "aws_sns_topic" "main" {
  name              = local.bucket_name
  kms_master_key_id = var.kms_key_id
  policy            = data.aws_iam_policy_document.main.json
  tags = {
    Env        = var.env
    Rev        = var.rev
    CreatedFor = "Bucket ${local.bucket_name}"
  }
}

data "aws_iam_policy_document" "main" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    actions   = ["SNS:Publish"]
    resources = ["arn:aws:sns:*:*:${local.bucket_name}"]
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.main.arn]
    }
  }
}

resource "random_pet" "bucket" {
  length = 2
}
