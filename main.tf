data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "lambda_fun.zip"
}

resource "aws_lambda_function" "copytobucket" {
  filename      = "lambda_fun.zip"
  function_name = "CopyToBucket"
  role          = var.lambda_role
  handler       = "lambda_function.handler_function"

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.12"
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.copytobucket.arn
  principal     = "s3.amazonaws.com"
  source_arn    = var.first_bucket_arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = var.first_bucket_short_arn

  lambda_function {
    lambda_function_arn = aws_lambda_function.copytobucket.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = ""
    filter_suffix       = ""
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}
