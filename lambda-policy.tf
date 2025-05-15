resource "aws_iam_role" "account_status_lambda_role" {
  name = "account-status-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  # 1) DynamoDB read‐only inline policy
  inline_policy {
    name   = "DynamoDBReadOnly"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [{
        Effect   = "Allow",
        Action   = ["dynamodb:GetItem", "dynamodb:Query"],
        Resource = "arn:aws:dynamodb:${var.region}:${var.account_id}:table/${var.account_request_status_table}"
      }]
    })
  }

  # 2) ENI access inline policy
  inline_policy {
    name   = "VPCENIAccess"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [{
        Effect = "Allow",
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ],
        Resource = "*"
      }]
    })
  }

  # 3) CloudWatch Logs inline policy
  inline_policy {
    name   = "LambdaWriteLogs"
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [{
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:${var.region}:${var.account_id}:log-group:${aws_cloudwatch_log_group.account_request_logging.name}:*"
      }]
    })
  }
}
