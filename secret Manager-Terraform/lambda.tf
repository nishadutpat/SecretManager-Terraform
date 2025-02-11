resource "aws_lambda_function" "secret_rotation_lambda" {
  filename         = "rotation_lambda.zip"
  function_name    = "SecretRotationFunction"
  role             = aws_iam_role.secret_rotation_role.arn
  handler         = "lambda_function.lambda_handler"
  runtime         = "python3.9"
  timeout         = 60

  source_code_hash = filebase64sha256("rotation_lambda.zip")
}

resource "aws_iam_role" "secret_rotation_role" {
  name = "secret_rotation_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_policy" "secret_rotation_policy" {
  name = "secret_rotation_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:PutSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:UpdateSecretVersionStage"
        ]
        Resource = aws_secretsmanager_secret.example.arn
      },
      {
        Effect   = "Allow"
        Action   = ["lambda:InvokeFunction"]
        Resource = aws_lambda_function.secret_rotation_lambda.arn
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "attach_secret_rotation_policy" {
  role       = aws_iam_role.secret_rotation_role.name
  policy_arn = aws_iam_policy.secret_rotation_policy.arn
}

resource "aws_lambda_permission" "allow_secret_manager" {
  statement_id  = "AllowSecretsManagerInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.secret_rotation_lambda.function_name
  principal     = "secretsmanager.amazonaws.com"
}
