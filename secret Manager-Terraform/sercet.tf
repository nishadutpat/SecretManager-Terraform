

resource "aws_secretsmanager_secret" "example" {
  name        = "my-secret"
  description = "sample secret "
}

resource "aws_secretsmanager_secret_version" "example" {
  secret_id     = aws_secretsmanager_secret.example.id
  secret_string = jsonencode({
    username = "admin"
    password = "sample@123"
  })
}

resource "aws_secretsmanager_secret_rotation" "example" {
  secret_id           = aws_secretsmanager_secret.example.id
  rotation_lambda_arn = aws_lambda_function.secret_rotation_lambda.arn

  rotation_rules {
    automatically_after_days = 1
  }
}
