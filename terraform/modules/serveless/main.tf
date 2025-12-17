resource "aws_ecr_repository" "app_repo" {
  name                 = "${var.project_name}-repo"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

resource "aws_lambda_function" "csv_processor" {
  function_name = "${var.project_name}-function"
  role          = var.iam_role_arn
  package_type  = "Image"
  image_uri     = var.image_uri 
  timeout       = 60 
  memory_size   = 128

  environment {
    variables = {
      OUTPUT_PREFIX = "output/"
    }
  }

  lifecycle {
    ignore_changes = [image_uri] 
  }
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.csv_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.bucket_arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = var.bucket_id

  lambda_function {
    lambda_function_arn = aws_lambda_function.csv_processor.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "input/"
    filter_suffix       = ".csv"
  }

  depends_on = [aws_lambda_permission.allow_s3]
}

output "repository_url" { value = aws_ecr_repository.app_repo.repository_url }