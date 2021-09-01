
data "archive_file" "lambda" {
  type             = "zip"
  source_dir       = "${path.module}/auto_verifier_lambda"
  output_path      = "${path.module}/verifier_lambda.zip"
  output_file_mode = "0755"
}

resource "aws_lambda_function" "auto_verifier" {
  filename         = "${path.module}/verifier_lambda.zip"
  function_name    = "${var.namespace}-${var.stage}-auto-verifier"
  description      = "ses auto verifier"
  runtime          = "python3.8"
  role             = aws_iam_role.default.arn
  handler          = "main.lambda_handler"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  tags             = var.tags

  environment {
    variables = {
      BUCKET = var.bucket_id
    }
  }
}

resource "aws_iam_role" "default" {
  name               = "${var.namespace}-${var.stage}-auto-verifier"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags               = var.tags
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "default" {
  name   = "${var.namespace}-${var.stage}-auto-verifier"
  role   = aws_iam_role.default.name
  policy = data.aws_iam_policy_document.default.json
}

data "aws_iam_policy_document" "default" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    effect = "Allow"

    resources = ["arn:aws:logs:*:*:*"]
  }

  statement {
    actions = [
      "s3:GetObject",
    ]

    effect = "Allow"

    resources = ["${var.bucket_arn}/*"]
  }

}

resource "aws_cloudwatch_log_group" "default" {
  name              = "/aws/lambda/${aws_lambda_function.auto_verifier.function_name}"
  retention_in_days = var.log_retention
}

data "aws_caller_identity" "current" {}

resource "aws_lambda_permission" "s3_notification" {
  statement_id   = "AllowExecutionS3Notification"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.auto_verifier.arn
  principal      = "s3.amazonaws.com"
  source_account = data.aws_caller_identity.current.account_id
  source_arn     = var.bucket_arn
}

resource "aws_s3_bucket_notification" "bounce_mail" {
  bucket = var.bucket_id

  lambda_function {
    id                  = "new_bounce"
    lambda_function_arn = aws_lambda_function.auto_verifier.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = var.mail_s3_bucket_prefix
    filter_suffix       = ""
  }

}
