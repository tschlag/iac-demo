data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowLambdaExecution"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.public_lambda.function_name
  principal     = "*"
}

resource "aws_lambda_function" "public_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "DivvyCloud-Org-CloudTrail-Lambda.zip"
  function_name = "public_lambda_test"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.lambda_handler"

  runtime = "python3.7"

  environment {
    variables = {
      env = "dev"
    }
  }
}