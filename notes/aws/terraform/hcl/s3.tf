
# code bucket
resource "aws_s3_bucket" "bucket-a" {
  bucket = "bucket-a"
  tags = {
    Name    = "bucket-a"
    Project = "backend"
  }
}
resource "aws_s3_bucket_cors_configuration" "bucket-a" {
  bucket = aws_s3_bucket.bucket-a.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "HEAD"]
    allowed_origins = [
      "*.example.com",
    ]
    expose_headers  = []
    max_age_seconds = 3000
  }
}
resource "aws_s3_bucket_ownership_controls" "bucket-a" {
  bucket = aws_s3_bucket.bucket-a.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
resource "aws_s3_bucket_public_access_block" "bucket-a" {
  bucket = aws_s3_bucket.bucket-a.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
resource "aws_s3_bucket_acl" "bucket-a" {
  depends_on = [
    aws_s3_bucket_ownership_controls.bucket-a,
    aws_s3_bucket_public_access_block.bucket-a,
  ]

  bucket = aws_s3_bucket.bucket-a.id
  acl    = "public-read"
}
resource "aws_s3_bucket_policy" "bucket-a" {
  bucket = aws_s3_bucket.bucket-a.id
  policy = data.aws_iam_policy_document.bucket-a-policy.json
}
data "aws_iam_policy_document" "bucket-a-policy" {
  statement {
    sid = "AllowPublicRead"
    actions = [
      "s3:GetObject",
    ]
    # actions = [
    #   "s3:GetObject",
    #   "s3:ListBucket",
    # ]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [
      aws_s3_bucket.bucket-a.arn,
      "${aws_s3_bucket.bucket-a.arn}/*",
    ]
    effect = "Allow"
  }
}



# file bucket
resource "aws_s3_bucket" "bucket-file" {
  bucket = "bucket-file"
  tags = {
    Name    = "bucket-file"
    Project = "frontend"
  }
}
resource "aws_s3_bucket_cors_configuration" "bucket-file" {
  bucket = aws_s3_bucket.bucket-file.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT"]
    allowed_origins = [
      "*.example.com",
    ]
    expose_headers  = ["x-amz-server-side-encryption", "x-amz-request-id", "x-amz-id-2"]
    max_age_seconds = 3000
  }
}
resource "aws_s3_bucket_ownership_controls" "bucket-file" {
  bucket = aws_s3_bucket.bucket-file.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}
resource "aws_s3_bucket_public_access_block" "bucket-file" {
  bucket = aws_s3_bucket.bucket-file.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
resource "aws_s3_bucket_policy" "bucket-file" {
  bucket = aws_s3_bucket.bucket-file.id
  policy = data.aws_iam_policy_document.bucket-file-policy.json
}
data "aws_iam_policy_document" "bucket-file-policy" {
  statement {
    sid = "AllowPublicRead"
    actions = [
      "s3:GetObject",
    ]
    # actions = [
    #   "s3:GetObject",
    #   "s3:ListBucket",
    # ]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [
      aws_s3_bucket.bucket-file.arn,
      "${aws_s3_bucket.bucket-file.arn}/*",
    ]
    effect = "Allow"
  }
}
# file bucket resized
resource "aws_s3_bucket" "bucket-file-resized" {
  bucket = "bucket-file-resized"
  tags = {
    Name    = "bucket-file-resized"
    Project = "frontend"
  }
}
resource "aws_s3_bucket_cors_configuration" "bucket-file-resized" {
  bucket = aws_s3_bucket.bucket-file-resized.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT"]
    allowed_origins = [
      "*.example.com",
    ]
    expose_headers  = ["x-amz-server-side-encryption", "x-amz-request-id", "x-amz-id-2"]
    max_age_seconds = 3000
  }
}
resource "aws_s3_bucket_ownership_controls" "bucket-file-resized" {
  bucket = aws_s3_bucket.bucket-file-resized.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}
resource "aws_s3_bucket_public_access_block" "bucket-file-resized" {
  bucket = aws_s3_bucket.bucket-file-resized.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "bucket-file-resized" {
  bucket = aws_s3_bucket.bucket-file-resized.id
  policy = data.aws_iam_policy_document.bucket-file-resized-policy.json
}
data "aws_iam_policy_document" "bucket-file-resized-policy" {
  statement {
    sid = "AllowPublicRead"
    actions = [
      "s3:GetObject",
    ]
    # actions = [
    #   "s3:GetObject",
    #   "s3:ListBucket",
    # ]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [
      aws_s3_bucket.bucket-file-resized.arn,
      "${aws_s3_bucket.bucket-file-resized.arn}/*",
    ]
    effect = "Allow"
  }
}
