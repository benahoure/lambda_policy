# 1) The Lambda execution role
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
}

# 2) DynamoDB read-only inline policy
resource "aws_iam_role_policy" "ddb_read" {
  name = "AccountStatusDDBReadPolicy"
  role = aws_iam_role.account_status_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["dynamodb:GetItem", "dynamodb:Query"],
      Resource = "arn:aws:dynamodb:${var.region}:${var.account_id}:table/${var.account_request_status_table}"
    }]
  })
}

# 3) VPC ENI access inline policy
resource "aws_iam_role_policy" "eni_access" {
  name = "LambdaVPCENIAccessPolicy"
  role = aws_iam_role.account_status_lambda_role.id

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

# 4) CloudWatch Logs write inline policy
resource "aws_iam_role_policy" "lambda_logs" {
  name = "LambdaWriteLogsPolicy"
  role = aws_iam_role.account_status_lambda_role.id

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
