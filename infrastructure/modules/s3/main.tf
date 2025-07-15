resource "aws_s3_bucket" "avatars" {
  bucket = var.bucket_name

  tags = merge(var.tags, {
    Name        = "${var.environment}-s3"
    Environment = "Dev"
  })
}

resource "aws_s3_object" "folder" {
  bucket = aws_s3_bucket.avatars.bucket
  key    = var.folder_name
  source = "/dev/null"
  content_type = "application/x-directory"
}
