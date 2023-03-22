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
  name               = "lambda_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}

resource "aws_lambda_permission" "allow_invoke" {
  statement_id  = "AllowLambdaExecution"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.public_lambda.function_name
  principal     = "*"
}

resource "aws_lambda_function" "public_lambda" {
  filename      = "Lambda-Code.zip"
  function_name = "eks_lambda"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.lambda_handler"

  runtime = "python3.7"

  environment {
    variables = {
      env = "dev"
    }
  }
}